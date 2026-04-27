using EMRSimulation.Application.Services;
using EMRSimulation.Domain.Dtos;
using EMRSimulationWebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Reflection.Emit;

namespace EMRSimulationWebApp.Controllers
{
    [Authorize]
    public class SupervisorController : Controller
    {
        private readonly IPatientService _patientService;
        private readonly ILabService _LabService;
        public SupervisorController(IPatientService patientService, ILabService LabService)
        {
            _patientService = patientService;
            _LabService = LabService;
        }

        public async Task<IActionResult> GetMemberOrder()
        {
            return PartialView("~/views/patient/_patientIvFluidChartAdd.cshtml");
        }

        public async Task<IActionResult> AddIvFluidChart([FromBody] IvFluidChartDto addsDto)
        {
            if (addsDto == null)
            {
                return BadRequest("Patient ADDS data is required.");
            }

            try
            {
                var newId = await _patientService.AddIvFluidChartsync(addsDto);
                return Ok(newId);
            }
            catch (Exception ex)
            {
                // Log the exception
                return StatusCode(500, "An error occurred while adding the patient adds." + ex);
            }
        }

        //neurological and Fluidbalance
        public IActionResult GetFluidRecord()
        {
            return PartialView("~/views/patient/_patientFluidBalanceChartAdd.cshtml");
        }
        [HttpPost]
        public async Task<IActionResult> AddFluidBalanceChart([FromBody] FluidBalanceChartDto dto)
        {
            if (dto == null) return BadRequest("Payload required.");

            // Derive totals server-side as a safety measure
            dto.Balance = dto.TotalIntake - dto.TotalOutput;
            dto.TotalBalance = dto.Balance + dto.PreviousDayBalance;

            var chartId = await _patientService.AddFluidBalanceChartAsync(dto);
            if (chartId <= 0) return StatusCode(500, "Insert failed.");

            // Persist each entry row
            foreach (var entry in dto.Entries ?? new())
            {
                entry.FluidBalanceChartId = chartId;
                await _patientService.AddFluidBalanceChartEntryAsync(entry);
            }

            return Ok(chartId);
        }
        // GET /supervisor/getpatientfluidbalancechartlist?labId=1&patientId=2
        public async Task<IActionResult> GetPatientFluidBalanceChartList(int labId, int patientId)
        {
            var list = await _patientService.GetFluidBalanceChartsAsync(labId, patientId);
            return PartialView("~/Views/Patient/_patientFluidRecordList.cshtml", list);
        }

        // GET /supervisor/deletefluidbalancechart?Id=5
        public async Task<IActionResult> DeleteFluidBalanceChart(int Id)
        {
            var (id, msg) = await _patientService.DeleteFluidBalanceChartAsync(Id);
            return Ok(new { id, resultMessage = msg });
        }
        public IActionResult GetNeurologicalRecord()
        {
            return PartialView("~/views/patient/_patientNeurologicalChartAdd.cshtml");
        }
        public async Task<IActionResult> AddNeurologicalChart([FromBody] NeurologicalChartDto addsDto)
        {
            if (addsDto == null)
            {
                return BadRequest("Patient ADDS data is required.");
            }

            try
            {
                var newId = await _patientService.AddNeurologicalChartsync(addsDto);
                return Ok(newId);
            }
            catch (Exception ex)
            {
                // Log the exception
                return StatusCode(500, "An error occurred while adding the patient adds." + ex);
            }
        }


        public async Task<IActionResult> GetMedicationPrn(int labId)
        {
            var medications = await _patientService.GetMedicationAsync(labId);

            return PartialView("~/views/patient/_patientMedicationPrnAdd.cshtml", medications);
        }

        public async Task<IActionResult> AddMedicationPrnChart([FromBody] MedicationPrnChartDto addsDto)
        {
            if (addsDto == null)
            {
                return BadRequest("Patient ADDS data is required.");
            }

            try
            {
                var newId = await _patientService.AddMedicationPrnChartAsync(addsDto);
                return Ok(newId);
            }
            catch (Exception ex)
            {
                // Log the exception
                return StatusCode(500, "An error occurred while adding the patient adds." + ex);
            }
        }

        public async Task<IActionResult> GetMedicationRegular(int labId)
        {
            var medications = await _patientService.GetMedicationAsync(labId);
            return PartialView("~/views/patient/_patientMedicationRegularAdd.cshtml", medications);
        }

        public async Task<IActionResult> AddMedicationRegularChart([FromBody] MedicationRegularChartDto addsDto)
        {
            if (addsDto == null)
            {
                return BadRequest("Patient ADDS data is required.");
            }

            try
            {
                var newId = await _patientService.AddMedicationRegularChartAsync(addsDto);
                return Ok(newId);
            }
            catch (Exception ex)
            {
                // Log the exception
                return StatusCode(500, "An error occurred while adding the patient adds." + ex);
            }
        }

        public async Task<IActionResult> GetSupervisorPatientList(int labId)
        {
            IEnumerable<PatientDto> lstPatients;

            lstPatients = await _patientService.GetAllPatientsAsync(labId);
            return PartialView("~/views/patient/_supervisorPatientList.cshtml", lstPatients);
        }

        public async Task<IActionResult> ClearPatientData(int labId, int patientId)
        {
            try
            {
                var clearedData = await _patientService.ClearPatientDataAsync(labId, patientId);
                return Ok(clearedData);
            }
            catch (Exception ex)
            {
                // Log the exception
                return StatusCode(500, "An error occurred while delete the Patient data." + ex);
            }
        }

        public async Task<IActionResult> ClearLabData(int labId)
        {
            try
            {
                var clearedData = await _patientService.ClearLabDataAsync(labId);
                return Ok(clearedData);
            }
            catch (Exception ex)
            {
                // Log the exception
                return StatusCode(500, "An error occurred while delete the Patient data." + ex);
            }
        }

        public async Task<IActionResult> GetSupervisorLabList(int labId)
        {
            LabDto Lab;

            Lab = await _LabService.GetLabById(labId);

            return PartialView("~/views/patient/_supervisorLabList.cshtml", Lab);
        }

        public async Task<IActionResult> GetPatient()
        {
            return PartialView("~/views/patient/_patientAdd.cshtml");
        }

        public async Task<IActionResult> AddPatient([FromBody] PatientDto addsDto)
        {
            if (addsDto == null)
            {
                return BadRequest("Patient data is required.");
            }

            try
            {
                var newId = await _patientService.AddPatientAsync(addsDto);
                return Ok(newId);
            }
            catch (Exception ex)
            {
                // Log the exception
                return StatusCode(500, "An error occurred while adding the patient adds." + ex);
            }
        }

        public async Task<IActionResult> DeletePatient(int labId, int Id)
        {
            int result = await _patientService.DeletePatientAsync(labId, Id);
            return Ok(result);
        }

        public async Task<IActionResult> GetMedication()
        {
            return PartialView("~/views/patient/_medicationAdd.cshtml");
        }

        public async Task<IActionResult> AddMedication([FromBody] MedicationDto addsDto)
        {
            if (addsDto == null)
            {
                return BadRequest("Medication data is required.");
            }

            try
            {
                var newId = await _patientService.AddMedicationAsync(addsDto);
                return Ok(newId);
            }
            catch (Exception ex)
            {
                // Log the exception
                return StatusCode(500, "An error occurred while adding the patient adds." + ex);
            }
        }

        public async Task<IActionResult> GetMedicationList(int labId)
        {
            IEnumerable<MedicationDto> lstPatients;

            lstPatients = await _patientService.GetMedicationAsync(labId);

            return PartialView("~/views/patient/_medicationList.cshtml", lstPatients);
        }

        public async Task<IActionResult> DeleteMedication(int Id)
        {
            var (id, resultMessage) = await _patientService.DeleteMedicationAsync(Id);
            return Ok(new { id = id, resultMessage = resultMessage });
        }

        public async Task<IActionResult> GetPatientIvFluidChartList(int labId, int patientId)
        {
            IEnumerable<IvFluidChartDto> lstIvFluidChartDto;

            lstIvFluidChartDto = await _patientService.GetIvFluidChartAsync(labId, patientId);

            return PartialView("~/views/patient/_patientMemberOrderList.cshtml", lstIvFluidChartDto);
        }

        public async Task<IActionResult> DeleteIvFluidChart(int Id)
        {
            var (id, resultMessage) = await _patientService.DeleteIvFluidChartAsync(Id);
            return Ok(new { id = id, resultMessage = resultMessage });
        }


        public async Task<IActionResult> GetPatientNeurologicalChartList(int labId, int patientId)
        {
            IEnumerable<NeurologicalChartDto> lstNeurologicalChartDto;

            lstNeurologicalChartDto = await _patientService.GetNeurologicalChartAsync(labId, patientId);

            return PartialView("~/views/patient/_patientNeurologicalRecordList.cshtml", lstNeurologicalChartDto);
        }

        public async Task<IActionResult> DeleteNeurologicaleChart(int Id)
        {
            var (id, resultMessage) = await _patientService.DeleteNeurologicalChartAsync(Id);
            return Ok(new { id = id, resultMessage = resultMessage });
        }

        
        public async Task<IActionResult> GetPatientMedicationPrnList(int labId, int patientId)
        {
            IEnumerable<MedicationPrnChartDto> lstMedicationPrnChartDto;
            lstMedicationPrnChartDto = await _patientService.GetMedicationPrnChartAsync(labId, patientId);

            return PartialView("~/views/patient/_patientMedicationChartPrnList.cshtml", lstMedicationPrnChartDto);
        }

        public async Task<IActionResult> DeleteMedicationPrnChart(int Id)
        {
            var (id, resultMessage) = await _patientService.DeleteMedicationPrnChartAsync(Id);
            return Ok(new { id = id, resultMessage = resultMessage });
        }


        public async Task<IActionResult> GetPatientMedicationRegularList(int labId, int patientId)
        {
            IEnumerable<MedicationRegularChartDto> lstMedicationRegularChartDto;
            lstMedicationRegularChartDto = await _patientService.GetMedicationRegularChartAsync(labId, patientId);

            return PartialView("~/views/patient/_patientMedicationChartRegularList.cshtml", lstMedicationRegularChartDto);
        }

        public async Task<IActionResult> DeleteMedicationRegularChart(int Id)
        {
            var (id, resultMessage) = await _patientService.DeleteMedicationRegularChartAsync(Id);
            return Ok(new { id = id, resultMessage = resultMessage });
        }


    }
}
