# Changelog

Sprint-by-sprint record of what changed and why.

Commit messages are kept short. The reasoning behind each change lives here.

---

## Sprint 3 — Semester 2, 2026

Three deliverables, from Naomi Cruz's welcome letter of 21 July 2026.

### 1. Global Module Repository *(her highest priority)*

Academics previously had to repopulate every patient chart by hand before each
laboratory class. This adds a repository so a scenario can be built once, saved,
and reused.

**Structure.** A `YearLevel → Unit → Module` hierarchy, with `Patient.ModuleId`
so a module owns its own patient record.

Module-owned rows use `LabId = 0` rather than `NULL`. `Lab.Id` is
`IDENTITY(1,1)`, so 0 can never collide with a real campus, and four tables —
`BradenAssessment`, `FallRiskAssessments`, `FoodIntakeHeader` and
`RiskmanIncident` — declare `LabId NOT NULL` and would reject `NULL` outright.

Unlike the Sprint 1/2 tables, the new ones declare foreign keys. These are
confined to the new subtree so no existing behaviour changes.

**Procedures.** Thirteen covering year level and unit maintenance, the module
browse, and create, rename, copy and delete.

`CopyModule` duplicates a module, its patient and every clinical chart, remapping
identity keys with `MERGE ... OUTPUT` — a plain `INSERT ... OUTPUT` cannot emit a
source column alongside the new identity. Each source set is spooled to a temp
table first, because every one of these statements reads the table it writes to.

`DeleteModule` cascades children before parents across all 21 clinical tables.

`GetModules` is deliberately not filtered by `LabId` or supervisor: the
repository is shared across all three campus logins, which is what Naomi asked
for.

**Re-scoping.** 23 existing procedures used `WHERE LabId = @LabId`, which
returned nothing for module patients. These became
`WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)`. Existing callers are
unaffected — passing a real `LabId` behaves exactly as before, while passing 0
switches to module mode and scopes on `PatientId` alone. They were generated
from the original definitions rather than hand-edited.

Deliberately excluded: `ClearLabData`, whose predicate has no `PatientId`, so
making it optional would let one call clear every campus.

**Screens.** Supervisors browse, filter, search, create, copy, rename and delete.
Students may browse and open, but every management action is gated on the
supervisor role and the controls are not rendered for them at all.

The module patient screen is what makes a module populatable: the existing
supervisor patient list has no Select, so reusing it left every chart screen
without a patient.

**One patient per module**, per Naomi's documents.

### 2. Load into lab — "Option B"

A module is a master copy. An academic loads it into their campus lab before
class; students work on that copy; loading again resets it. The module is never
written to.

Three columns on `Patient` distinguish the three kinds of patient:

| `LabId` | `ModuleId` | `SourceModuleId` | what it is |
|---|---|---|---|
| `<lab>` | `NULL` | `NULL` | an ordinary campus patient |
| `0` | `<module>` | `NULL` | the module's master patient |
| `<lab>` | `NULL` | `<module>` | a lab copy loaded from a module |

`SourceModuleId` is what makes reloading safe. Without it, resetting a lab would
mean clearing the whole lab and destroying every unrelated patient the campus had
set up. With it, a reload replaces exactly one patient and its charts.

**No foreign key on `SourceModuleId`, deliberately.** Lab copies are not deleted
with their module, so a key would block `DeleteModule` for any module ever loaded
into a lab. Students' work should not stop an academic tidying the repository.
Deleting a module leaves its copies as ordinary patients.

`LoadModuleIntoLab` is generated from `CopyModule` with `@ModuleLabId` replaced
by `@LabId`, so the two cannot drift in what they copy. It refuses `LabId = 0`,
which marks module-owned rows — a copy taken with it would be indistinguishable
from the master.

The target lab comes from the signed-in supervisor's claim and is never read from
the request. `LoadIntoLabRequest` carries only `ModuleId`, so there is nothing for
a client to set. Accepting it would let one campus load over another's lab.

Verified across two campus logins: each gets its own copy, two modules coexist in
one lab, and reloading leaves unrelated patients untouched.

### 3. ADDS chart — oxygen fields

Naomi's task 3. An `N/A` option on the oxygen flow rate, and a Mode of Delivery
field offering Room Air (RA), Intra Nasal Cannula (INC) and Hudson Mask (HM).

`N/A` needs no schema change — `OxygenFlow` is `varchar(20)` and stores the
literal. Mode of Delivery is a new column, nullable because observations recorded
before this sprint have no value and there is no clinically safe default.

Ticking N/A clears and disables the flow rate dropdown rather than hiding it, and
contributes 0 to the ADDS score. Mode of Delivery stays required: no supplemental
oxygen is recorded as Room Air, not left blank.

This is the minimal change the document asks for, deliberately separate from the
wider ADDS redesign in the wireframe, which has not been agreed with the client.

The escalation guidance was also changed from a half-width image to readable
text, transcribed from that same image so the clinical content is unchanged.

### 4. Progress notes — date and time

Naomi's task 4. Selectable date and time when creating a note, both displayed
when viewing, delete removed from the student login and edit enabled.

Three procedure defects were found and fixed:

- `UpdateProgressNote` declared `@Notes` as `VARCHAR(500)` against a `TEXT`
  column. Unreachable before, because there was no edit screen; enabling edit
  would have silently truncated any note over 500 characters.
- `GetProgressNotes` ordered by `NotesFrom` — the author's role, not a time — so
  every supervisor note sorted above every student note regardless of when either
  was written.
- `GetProgressNoteById` is new, needed so the server can read a note's author
  before permitting an edit or delete.

Hiding the delete button does not remove the capability, so both edit and delete
now verify the note was written from the caller's own role, and an edit preserves
the original author rather than overwriting it with the current user's.

---

## Defects found and fixed during Sprint 3

**Progress note list crashed on notes of 51–69 characters.** The preview guarded
on `Notes.Length > 50` but called `Substring(0, 70)`. Razor fails the whole view
on one bad row, so a single ordinary sentence — *"Patient resting comfortably,
observations stable, no concerns."* is 61 characters — blanked the entire progress
note list for that patient, not just that note. Pre-existing and latent since the
list was written.

**Cross-campus data leak.** The campus `LabId` was restored on the bubble phase
when leaving a module, which ran after the menu handlers, so lab-scoped screens
briefly ran with `LabId = 0` and read across every campus. Fixed by moving the
restore to the capture phase, limited to an explicit list of campus-scoped
destinations.

**Module data written to a campus.** The above fix, applied too broadly, meant
opening a chart from inside a module silently returned to campus mode while still
holding the module patient. Two corrupt rows resulted; a repair script corrected
them.

**Mode of Delivery dropped on copy.** `CopyModule` lists the `PatientAdds`
columns explicitly, so a column added later was silently omitted — a copied
module returned every observation with a blank mode and no error. The same
mistake was then repeated in `LoadModuleIntoLab` by generating it from the older
procedure definition. A drift check now compares both procedures' column
references across all 19 clinical tables.

**`Forbid()` returned 404 rather than 403.** Under cookie authentication it
redirects to `AccessDeniedPath`, which does not exist here. Actions were
correctly refused throughout; only the response was misleading.

**`.gitignore` was UTF-16 corrupted.** A `*.bak` rule added in `4924e9b` was
written as UTF-16 and concatenated onto the `FodyWeavers.xsd` line with no
newline, leaving 7 NUL bytes. Git classified the file as binary from that point,
so every change to it showed as "Binary files differ" with no visible diff.

---

## Known issues

**`GetPatientList` trusts the `labId` query parameter.** Any authenticated user
can read another campus's patient list by changing it. Pre-existing, and the same
root cause as the cross-campus leak above: the campus is treated as a
client-supplied parameter rather than an identity.

**Credentials in source control.** `appsettings.json` and
`appsettings.Development.json` contain the SQL Server `sa` password in plain
text, and both are in the repository history.

**Passwords are stored and compared in plain text.** `users.sql` seeds
`lab123 / lab123` and `super / super`; the login procedure compares them
directly.

**Supervisors cannot edit or delete an ADDS observation.** The delete button
appears only on the student login and there is no edit path for anyone, so an
academic who mistypes an observation while preparing a module cannot correct it.

**No way to remove a loaded copy through the UI.** At the end of semester an
academic would accumulate copies from every week they ran, with no button to
clear them.

---

## Database

`Database/EMRSimulatorFULL-spr3.sql` is a schema-only export of the database as
it stands at the end of Sprint 3: 27 tables, 77 procedures, no data. It builds a
fresh database and does **not** upgrade an existing one — rebuild from it rather
than trying to patch.
