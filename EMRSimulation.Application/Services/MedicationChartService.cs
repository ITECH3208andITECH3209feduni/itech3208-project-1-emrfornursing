using EMRSimulation.Application.Interfaces;
using EMRSimulation.Domain.Dtos;

namespace EMRSimulation.Application.Services
{
    public class MedicationChartService : IMedicationChartService
    {
        private readonly IMedicationChartRepository _repository;

        public MedicationChartService(IMedicationChartRepository repository)
        {
            _repository = repository;
        }

        public Task<IReadOnlyList<MedicationChartOrderDto>> GetOrdersAsync(int labId, int patientId)
            => _repository.GetOrdersAsync(labId, patientId);

        public Task<MedicationChartOrderDto?> GetOrderAsync(int id)
            => _repository.GetOrderAsync(id);

        public Task<IReadOnlyList<MedicationChartAdministrationDto>> GetAdministrationsAsync(int labId, int patientId, DateTime date)
            => _repository.GetAdministrationsAsync(labId, patientId, date);

        public Task<IReadOnlyList<MedicationChartAdministrationDto>> GetHistoryAsync(int orderId)
            => _repository.GetHistoryAsync(orderId);

        public Task<int> SaveOrderAsync(MedicationChartOrderDto order)
            => _repository.SaveOrderAsync(order);

        public Task<bool> DiscontinueOrderAsync(int id, string discontinuedBy)
            => _repository.DiscontinueOrderAsync(id, discontinuedBy);

        public Task<int> AddAdministrationAsync(MedicationChartAdministrationDto administration)
            => _repository.AddAdministrationAsync(administration);
    }
}
