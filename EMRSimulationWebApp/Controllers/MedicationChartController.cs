using EMRSimulation.Application.Services;
using EMRSimulation.Domain.Dtos;
using EMRSimulationWebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EMRSimulation.WebApp.Controllers
{
    [Authorize]
    public class MedicationChartController : Controller
    {
        private readonly IPatientService _patientService;
        private readonly IMedicationChartService _medicationChartService;

        public MedicationChartController(
            IPatientService patientService,
            IMedicationChartService medicationChartService)
        {
            _patientService = patientService;
            _medicationChartService = medicationChartService;
        }

        private string Role => User.FindFirst("Role")?.Value ?? string.Empty;
        private bool IsSupervisor => string.Equals(Role, "supervisor", StringComparison.OrdinalIgnoreCase);
        private bool IsStudent => string.Equals(Role, "student", StringComparison.OrdinalIgnoreCase);

        [HttpGet]
        public async Task<IActionResult> Index(int labId, int patientId, DateTime? date)
        {
            if (patientId <= 0)
                return BadRequest("Please select a patient first.");

            var claimLabId = GetClaimLabId();
            if (IsStudent && labId != claimLabId)
                return StatusCode(403, "You cannot open a patient from another lab.");
            if (IsSupervisor && labId != 0 && claimLabId > 0 && labId != claimLabId)
                return StatusCode(403, "You cannot open a patient from another lab.");

            var patient = await _patientService.GetPatientById(patientId, labId, IsSupervisor);
            if (patient == null || patient.Id <= 0)
                return NotFound("Patient not found.");

            var selectedDate = (date ?? DateTime.Today).Date;
            var medicationCatalogue = (await _patientService.GetMedicationAsync(labId))
                .Where(m => !string.IsNullOrWhiteSpace(m.Name))
                .OrderBy(m => m.Name)
                .ToList();
            var orders = await _medicationChartService.GetOrdersAsync(labId, patientId);
            var administrations = await _medicationChartService.GetAdministrationsAsync(labId, patientId, selectedDate);

            var model = new MedicationChartViewModel
            {
                Patient = patient,
                LabId = labId,
                PatientId = patientId,
                SelectedDate = selectedDate,
                MedicationCatalogue = medicationCatalogue,
                Orders = orders,
                Administrations = administrations
            };

            return PartialView("~/Views/MedicationChart/Index.cshtml", model);
        }

        [HttpGet]
        public async Task<IActionResult> GetOrder(int id)
        {
            var order = await _medicationChartService.GetOrderAsync(id);
            if (order == null)
                return NotFound("Medication order not found.");

            if (!CanAccessOrder(order))
                return StatusCode(403, "You cannot access this medication order.");

            return Ok(order);
        }

        [HttpGet]
        public async Task<IActionResult> History(int orderId)
        {
            var order = await _medicationChartService.GetOrderAsync(orderId);
            if (order == null)
                return NotFound("Medication order not found.");
            if (!CanAccessOrder(order))
                return StatusCode(403, "You cannot access this medication history.");

            var history = await _medicationChartService.GetHistoryAsync(orderId);
            return Ok(history.Select(x => new
            {
                id = x.Id,
                date = x.AdministrationDate.ToString("dd-MMM-yyyy"),
                hour = x.AdministrationHour,
                time = x.AdministrationHour.ToString("00") + "00",
                status = x.Status,
                dose = x.Dose,
                studentSignature = x.GivenBy,
                coSignature = x.CoSign,
                notes = x.Notes,
                recordedAt = x.AdministeredAt.ToLocalTime().ToString("dd-MMM-yyyy HH:mm")
            }));
        }

        [HttpPost]
        public async Task<IActionResult> SaveOrder([FromBody] MedicationChartOrderDto order)
        {
            if (!IsSupervisor)
                return StatusCode(403, "Only a supervisor can add or edit medication orders.");

            if (order == null)
                return BadRequest("Medication order is required.");

            NormaliseOrder(order);
            var validation = ValidateOrder(order);
            if (validation != null)
                return BadRequest(validation);

            var claimLabId = GetClaimLabId();
            if (order.LabId != 0 && claimLabId > 0 && order.LabId != claimLabId)
                return StatusCode(403, "This medication order does not belong to your lab.");

            try
            {
                var id = await _medicationChartService.SaveOrderAsync(order);
                return Ok(new { id, message = order.Id > 0 ? "Medication updated." : "Medication added." });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost]
        public async Task<IActionResult> Discontinue(int id)
        {
            if (!IsSupervisor)
                return StatusCode(403, "Only a supervisor can discontinue medication orders.");

            var order = await _medicationChartService.GetOrderAsync(id);
            if (order == null)
                return NotFound("Medication order not found.");

            var claimLabId = GetClaimLabId();
            if (order.LabId != 0 && claimLabId > 0 && order.LabId != claimLabId)
                return StatusCode(403, "This medication order does not belong to your lab.");

            var changed = await _medicationChartService.DiscontinueOrderAsync(id, "Supervisor");
            return changed ? Ok(new { message = "Medication discontinued." }) : BadRequest("Medication is already discontinued.");
        }

        [HttpPost]
        public async Task<IActionResult> RecordAdministration([FromBody] MedicationChartAdministrationDto administration)
        {
            if (!IsStudent && !IsSupervisor)
                return StatusCode(403, "Only an authorised student or supervisor can record medication administration.");

            if (administration == null)
                return BadRequest("Administration details are required.");

            var order = await _medicationChartService.GetOrderAsync(administration.MedicationOrderId);
            if (order == null)
                return NotFound("Medication order not found.");

            if (!string.Equals(order.Status, "Active", StringComparison.OrdinalIgnoreCase))
                return BadRequest("This medication has been discontinued and cannot be administered.");

            var claimLabId = GetClaimLabId();
            var canAccessLab = IsStudent
                ? order.LabId == claimLabId
                : (order.LabId == 0 || claimLabId == 0 || order.LabId == claimLabId);

            if (!canAccessLab || order.PatientId != administration.PatientId || order.LabId != administration.LabId)
                return StatusCode(403, "This medication order does not belong to the selected patient.");

            administration.AdministrationDate = administration.AdministrationDate.Date;
            administration.Status = (administration.Status ?? string.Empty).Trim();
            administration.Dose = (administration.Dose ?? string.Empty).Trim();
            administration.GivenBy = (administration.GivenBy ?? string.Empty).Trim();
            administration.CoSign = (administration.CoSign ?? string.Empty).Trim();
            administration.Notes = (administration.Notes ?? string.Empty).Trim();

            if (administration.AdministrationDate > DateTime.Today)
                return BadRequest("A future medication administration cannot be recorded.");

            if (administration.AdministrationHour < 0 || administration.AdministrationHour > 23)
                return BadRequest("Administration hour must be between 0000 and 2300.");

            if (administration.Status != "Given" && administration.Status != "Held" && administration.Status != "Missed")
                return BadRequest("Choose Given, Held or Missed.");

            if (string.Equals(order.MedicationType, "Regular", StringComparison.OrdinalIgnoreCase)
                && !order.ScheduleHours.Contains(administration.AdministrationHour))
                return BadRequest("That hour is not scheduled for this regular medication.");

            if (administration.Status == "Given" && string.IsNullOrWhiteSpace(administration.Dose))
                return BadRequest("Enter the dose actually administered.");

            if (string.IsNullOrWhiteSpace(administration.GivenBy))
                return BadRequest("Student signature is required.");

            if (string.IsNullOrWhiteSpace(administration.CoSign))
                return BadRequest("Second co-signature is required.");

            if (string.Equals(administration.GivenBy, administration.CoSign, StringComparison.OrdinalIgnoreCase))
                return BadRequest("The second co-signature must be completed by a different person.");

            if ((administration.Status == "Held" || administration.Status == "Missed") && string.IsNullOrWhiteSpace(administration.Notes))
                return BadRequest("Enter a reason for a held or missed medication.");

            if (string.Equals(order.MedicationType, "PRN", StringComparison.OrdinalIgnoreCase)
                && administration.Status == "Given" && string.IsNullOrWhiteSpace(administration.Notes))
                return BadRequest("Enter the clinical reason for giving this PRN medication.");

            try
            {
                var id = await _medicationChartService.AddAdministrationAsync(administration);
                return Ok(new { id, message = administration.Status == "Given" ? "Medication marked as given." : $"Medication marked as {administration.Status.ToLowerInvariant()}." });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(ex.Message);
            }
        }

        private int GetClaimLabId()
            => int.TryParse(User.FindFirst("labId")?.Value, out var id) ? id : 0;

        private bool CanAccessOrder(MedicationChartOrderDto order)
        {
            var claimLabId = GetClaimLabId();
            if (IsStudent)
                return order.LabId == claimLabId;
            if (IsSupervisor)
                return order.LabId == 0 || claimLabId == 0 || order.LabId == claimLabId;
            return false;
        }

        private static void NormaliseOrder(MedicationChartOrderDto order)
        {
            order.MedicationType = (order.MedicationType ?? string.Empty).Trim();
            order.MedicationName = (order.MedicationName ?? string.Empty).Trim();
            order.Strength = (order.Strength ?? string.Empty).Trim();
            order.Measure = (order.Measure ?? string.Empty).Trim();
            order.Route = (order.Route ?? string.Empty).Trim();
            order.Frequency = (order.Frequency ?? string.Empty).Trim();
            order.MaximumDose = (order.MaximumDose ?? string.Empty).Trim();
            order.Indication = (order.Indication ?? string.Empty).Trim();
            order.PrescriberName = (order.PrescriberName ?? string.Empty).Trim();
            order.PrescriberSignature = (order.PrescriberSignature ?? string.Empty).Trim();
            order.ScheduleHours = (order.ScheduleHours ?? new List<int>()).Distinct().OrderBy(x => x).ToList();
            // Persist value + unit in the existing Strength column so Sprint 5 can add an explicit
            // Measure field without changing or resetting the database schema.
            if (!string.IsNullOrWhiteSpace(order.Measure))
                order.Strength = $"{order.Strength} {order.Measure}".Trim();
            if (order.StartDate == default)
                order.StartDate = DateTime.Today;
            if (!string.Equals(order.MedicationType, "Regular", StringComparison.OrdinalIgnoreCase))
                order.ScheduleHours.Clear();
        }

        private static string? ValidateOrder(MedicationChartOrderDto order)
        {
            if (order.PatientId <= 0)
                return "Select a patient before adding medication.";

            var allowedTypes = new[] { "Regular", "PRN", "STAT" };
            var type = allowedTypes.FirstOrDefault(x => string.Equals(x, order.MedicationType, StringComparison.OrdinalIgnoreCase));
            if (type == null)
                return "Medication type must be Regular, PRN or STAT.";
            order.MedicationType = type;

            if (string.IsNullOrWhiteSpace(order.MedicationName)) return "Medication name is required.";
            if (string.IsNullOrWhiteSpace(order.Strength)) return "Dose / strength value is required.";
            if (string.IsNullOrWhiteSpace(order.Measure)) return "Measure / unit is required.";
            if (string.IsNullOrWhiteSpace(order.Route)) return "Route is required.";
            if (string.IsNullOrWhiteSpace(order.Frequency)) return "Frequency is required.";
            if (string.IsNullOrWhiteSpace(order.MaximumDose)) return "Maximum dose is required.";
            if (string.IsNullOrWhiteSpace(order.Indication)) return "Indication is required.";
            if (string.IsNullOrWhiteSpace(order.PrescriberName)) return "Prescriber name is required.";
            if (string.IsNullOrWhiteSpace(order.PrescriberSignature)) return "Prescriber signature is required.";
            if (order.EndDate.HasValue && order.EndDate.Value.Date < order.StartDate.Date) return "End date cannot be before the start date.";
            if (order.ScheduleHours.Any(x => x < 0 || x > 23)) return "Administration times must be between 0000 and 2300.";
            if (order.MedicationType == "Regular" && order.ScheduleHours.Count == 0) return "Choose at least one administration time for a regular medication.";

            return null;
        }
    }
}
