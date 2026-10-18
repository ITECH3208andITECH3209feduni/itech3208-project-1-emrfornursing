using EMRSimulation.Domain.Dtos;

namespace EMRSimulation.Application.Interfaces
{
    public interface IMedicationChartRepository
    {
        Task<IReadOnlyList<MedicationChartOrderDto>> GetOrdersAsync(int labId, int patientId);
        Task<MedicationChartOrderDto?> GetOrderAsync(int id);
        Task<IReadOnlyList<MedicationChartAdministrationDto>> GetAdministrationsAsync(int labId, int patientId, DateTime date);
        Task<IReadOnlyList<MedicationChartAdministrationDto>> GetHistoryAsync(int orderId);
        Task<int> SaveOrderAsync(MedicationChartOrderDto order);
        Task<bool> DiscontinueOrderAsync(int id, string discontinuedBy);
        Task<int> AddAdministrationAsync(MedicationChartAdministrationDto administration);
    }
}
