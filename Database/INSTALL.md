# Building the database from scratch

Run these **in order**, against a database named `EmrSimulator`.

| # | Script | What it does |
|---|--------|--------------|
| 1 | `EMRSimulatorFULL-spr4.sql` | Tables and stored procedures. No data. |
| 2 | `users.sql` | One laboratory and one supervisor login. |
| 3 | `Seed_YearLevelsAndUnits.sql` | Three year levels and the six NURBN unit codes. |

**Step 3 is not optional.** A module must belong to a Unit, which must belong to
a YearLevel, and there is no screen to create either yet. Without it the module
repository opens but nothing can be created in it.

Scripts 2 and 3 are safe to re-run.

---

## Hosting on a server

`EMRSimulatorFULL-spr4.sql` begins with a `CREATE DATABASE` that carries the
file paths from the machine it was scripted on:

```
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\EmrSimulator.mdf'
```

`MSSQL16` is SQL Server 2022 Express. On a server with a different version,
instance or data directory that fails before a single table is created.

**Create the database yourself, then run the script from `USE [EmrSimulator]`**
(around line 81). Everything from that point is server-independent.

---

## Testing a clean install without losing your working database

Use a second database rather than dropping the one you develop against:

1. In SSMS, create an empty database `EmrSimulator_Test`.
2. Open `EMRSimulatorFULL-spr4.sql`, delete everything above `USE [EmrSimulator]`,
   then replace `[EmrSimulator]` with `[EmrSimulator_Test]` and run it.
3. Run `users.sql` and `Seed_YearLevelsAndUnits.sql` against `EmrSimulator_Test`.
4. Point the application at it by setting an environment variable, so
   `appsettings.json` is left alone:

   ```powershell
   $env:ConnectionStrings__EmrSimulationConnection =
       "Server=.\SQLEXPRESS;Database=EmrSimulator_Test;Trusted_Connection=True;TrustServerCertificate=True;"
   dotnet run --project EMRSimulationWebApp
   ```

5. Work through the checklist below.
6. When finished, close the shell (the variable disappears with it) and drop
   `EmrSimulator_Test`.

---

## What to check on the fresh database

Anything that needs data the scripts do not create will fail here and only here.

- [ ] Sign in as supervisor (`super`) and as student (`lab123`)
- [ ] **Module repository lists the six NURBN unit codes** — if empty, step 3 was skipped
- [ ] Create a module; it should arrive with twelve blank patients
- [ ] Open the module and write a progress note against one of its patients
      (this is the path that used to be refused, because module scope is `labId = 0`)
- [ ] Add an ADDS observation and confirm the cells and total are colour-shaded
- [ ] Load the module into two laboratories
- [ ] Hide it from students in one of them, and confirm the other is unaffected
- [ ] Sign in as a student and confirm the hidden module's patients are absent
- [ ] Create an IV fluid chart (all eight parameters, fixed in this release)
- [ ] Confirm the patient list shows every patient on one page

---

## Before exporting the database again

Run `Cleanup_StaleSetModuleVisibility.sql` first. It drops a superseded
procedure and then reports any module referencing an object or column that no
longer exists.

SQL Server uses deferred name resolution: a procedure that references a dropped
column compiles, sits in the database indefinitely, and only fails when it is
executed or scripted into a fresh database. That is exactly how a stale
procedure reached Technical Services and broke their import.

When scripting in SSMS, set **Script Database Create = False** and
**encoding = UTF-8**. UTF-16 is git's default failure mode here: it stores the
file as a binary blob, so no one can review what changed between sprints.
