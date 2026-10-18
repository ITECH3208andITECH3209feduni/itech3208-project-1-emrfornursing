using EMRSimulation.Application.Interfaces;
using EMRSimulation.Domain.Dtos;
using EMRSimulation.Infrastructure.Connection;
using System.Data;
using System.Data.SqlClient;

namespace EMRSimulation.Infrastructure.Repositories
{
    public class MedicationChartRepository : IMedicationChartRepository
    {
        private readonly IDbConnectionFactory _dbConnectionFactory;

        public MedicationChartRepository(IDbConnectionFactory dbConnectionFactory)
        {
            _dbConnectionFactory = dbConnectionFactory;
        }

        public async Task<IReadOnlyList<MedicationChartOrderDto>> GetOrdersAsync(int labId, int patientId)
        {
            var orders = new List<MedicationChartOrderDto>();
            var lookup = new Dictionary<int, MedicationChartOrderDto>();

            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = @"
SELECT Id, LabId, PatientId, MedicationType, MedicationName, Strength, Route,
       Frequency, MaximumDose, Indication, PrescriberName, PrescriberSignature,
       StartDate, EndDate, Status, DiscontinuedAt, DiscontinuedBy, CreatedAt, UpdatedAt
FROM dbo.S5MedicationOrder
WHERE LabId = @LabId AND PatientId = @PatientId
ORDER BY CASE MedicationType WHEN 'Regular' THEN 1 WHEN 'PRN' THEN 2 ELSE 3 END,
         MedicationName;

SELECT s.MedicationOrderId, s.ScheduledHour
FROM dbo.S5MedicationSchedule s
INNER JOIN dbo.S5MedicationOrder o ON o.Id = s.MedicationOrderId
WHERE o.LabId = @LabId AND o.PatientId = @PatientId
ORDER BY s.MedicationOrderId, s.ScheduledHour;";
                command.Parameters.AddWithValue("@LabId", labId);
                command.Parameters.AddWithValue("@PatientId", patientId);

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var order = MapOrder(reader);
                        orders.Add(order);
                        lookup[order.Id] = order;
                    }

                    if (await reader.NextResultAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            var orderId = reader.GetInt32(reader.GetOrdinal("MedicationOrderId"));
                            var hour = reader.GetByte(reader.GetOrdinal("ScheduledHour"));
                            if (lookup.TryGetValue(orderId, out var order))
                                order.ScheduleHours.Add(hour);
                        }
                    }
                }
            }

            return orders;
        }

        public async Task<MedicationChartOrderDto?> GetOrderAsync(int id)
        {
            MedicationChartOrderDto? order = null;

            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = @"
SELECT Id, LabId, PatientId, MedicationType, MedicationName, Strength, Route,
       Frequency, MaximumDose, Indication, PrescriberName, PrescriberSignature,
       StartDate, EndDate, Status, DiscontinuedAt, DiscontinuedBy, CreatedAt, UpdatedAt
FROM dbo.S5MedicationOrder
WHERE Id = @Id;

SELECT MedicationOrderId, ScheduledHour
FROM dbo.S5MedicationSchedule
WHERE MedicationOrderId = @Id
ORDER BY ScheduledHour;";
                command.Parameters.AddWithValue("@Id", id);

                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                        order = MapOrder(reader);

                    if (order != null && await reader.NextResultAsync())
                    {
                        while (await reader.ReadAsync())
                            order.ScheduleHours.Add(reader.GetByte(reader.GetOrdinal("ScheduledHour")));
                    }
                }
            }

            return order;
        }

        public async Task<IReadOnlyList<MedicationChartAdministrationDto>> GetAdministrationsAsync(int labId, int patientId, DateTime date)
        {
            var items = new List<MedicationChartAdministrationDto>();

            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = @"
SELECT Id, MedicationOrderId, LabId, PatientId, AdministrationDate,
       AdministrationHour, Status, Dose, GivenBy, CoSign, Notes, AdministeredAt
FROM dbo.S5MedicationAdministration
WHERE LabId = @LabId AND PatientId = @PatientId AND AdministrationDate = @Date
ORDER BY AdministrationHour, Id;";
                command.Parameters.AddWithValue("@LabId", labId);
                command.Parameters.AddWithValue("@PatientId", patientId);
                command.Parameters.AddWithValue("@Date", date.Date);

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                        items.Add(MapAdministration(reader));
                }
            }

            return items;
        }

        public async Task<IReadOnlyList<MedicationChartAdministrationDto>> GetHistoryAsync(int orderId)
        {
            var items = new List<MedicationChartAdministrationDto>();

            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = @"
SELECT TOP (100) Id, MedicationOrderId, LabId, PatientId, AdministrationDate,
       AdministrationHour, Status, Dose, GivenBy, CoSign, Notes, AdministeredAt
FROM dbo.S5MedicationAdministration
WHERE MedicationOrderId = @OrderId
ORDER BY AdministrationDate DESC, AdministrationHour DESC, Id DESC;";
                command.Parameters.AddWithValue("@OrderId", orderId);

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                        items.Add(MapAdministration(reader));
                }
            }

            return items;
        }

        public async Task<int> SaveOrderAsync(MedicationChartOrderDto order)
        {
            using var connectionBase = await _dbConnectionFactory.CreateAsync();
            var connection = (SqlConnection)connectionBase;
            using var transaction = connection.BeginTransaction();

            try
            {
                int orderId;

                if (order.Id <= 0)
                {
                    using var insert = new SqlCommand(@"
INSERT INTO dbo.S5MedicationOrder
    (LabId, PatientId, MedicationType, MedicationName, Strength, Route, Frequency,
     MaximumDose, Indication, PrescriberName, PrescriberSignature, StartDate, EndDate,
     Status, CreatedAt, UpdatedAt)
VALUES
    (@LabId, @PatientId, @MedicationType, @MedicationName, @Strength, @Route, @Frequency,
     @MaximumDose, @Indication, @PrescriberName, @PrescriberSignature, @StartDate, @EndDate,
     'Active', SYSUTCDATETIME(), SYSUTCDATETIME());
SELECT CAST(SCOPE_IDENTITY() AS int);", connection, transaction);
                    AddOrderParameters(insert, order);
                    orderId = Convert.ToInt32(await insert.ExecuteScalarAsync());
                }
                else
                {
                    using var update = new SqlCommand(@"
UPDATE dbo.S5MedicationOrder
SET MedicationType = @MedicationType,
    MedicationName = @MedicationName,
    Strength = @Strength,
    Route = @Route,
    Frequency = @Frequency,
    MaximumDose = @MaximumDose,
    Indication = @Indication,
    PrescriberName = @PrescriberName,
    PrescriberSignature = @PrescriberSignature,
    StartDate = @StartDate,
    EndDate = @EndDate,
    UpdatedAt = SYSUTCDATETIME()
WHERE Id = @Id AND LabId = @LabId AND PatientId = @PatientId AND Status = 'Active';
SELECT @@ROWCOUNT;", connection, transaction);
                    AddOrderParameters(update, order);
                    update.Parameters.AddWithValue("@Id", order.Id);
                    var affected = Convert.ToInt32(await update.ExecuteScalarAsync());
                    if (affected == 0)
                        throw new InvalidOperationException("This medication order could not be updated. It may have been discontinued.");
                    orderId = order.Id;

                    using var deleteSchedules = new SqlCommand(
                        "DELETE FROM dbo.S5MedicationSchedule WHERE MedicationOrderId = @Id;",
                        connection, transaction);
                    deleteSchedules.Parameters.AddWithValue("@Id", orderId);
                    await deleteSchedules.ExecuteNonQueryAsync();
                }

                foreach (var hour in order.ScheduleHours.Distinct().OrderBy(x => x))
                {
                    using var schedule = new SqlCommand(@"
INSERT INTO dbo.S5MedicationSchedule (MedicationOrderId, ScheduledHour)
VALUES (@MedicationOrderId, @ScheduledHour);", connection, transaction);
                    schedule.Parameters.AddWithValue("@MedicationOrderId", orderId);
                    schedule.Parameters.AddWithValue("@ScheduledHour", hour);
                    await schedule.ExecuteNonQueryAsync();
                }

                transaction.Commit();
                return orderId;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<bool> DiscontinueOrderAsync(int id, string discontinuedBy)
        {
            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = @"
UPDATE dbo.S5MedicationOrder
SET Status = 'Discontinued',
    DiscontinuedAt = SYSUTCDATETIME(),
    DiscontinuedBy = @DiscontinuedBy,
    EndDate = COALESCE(EndDate, CAST(GETDATE() AS date)),
    UpdatedAt = SYSUTCDATETIME()
WHERE Id = @Id AND Status = 'Active';";
                command.Parameters.AddWithValue("@Id", id);
                command.Parameters.AddWithValue("@DiscontinuedBy", discontinuedBy ?? "Supervisor");
                return await command.ExecuteNonQueryAsync() > 0;
            }
        }

        public async Task<int> AddAdministrationAsync(MedicationChartAdministrationDto administration)
        {
            try
            {
                using (var connection = await _dbConnectionFactory.CreateAsync())
                using (var command = (SqlCommand)connection.CreateCommand())
                {
                    command.CommandType = CommandType.Text;
                    command.CommandText = @"
INSERT INTO dbo.S5MedicationAdministration
    (MedicationOrderId, LabId, PatientId, AdministrationDate, AdministrationHour,
     Status, Dose, GivenBy, CoSign, Notes, AdministeredAt)
VALUES
    (@MedicationOrderId, @LabId, @PatientId, @AdministrationDate, @AdministrationHour,
     @Status, @Dose, @GivenBy, @CoSign, @Notes, SYSUTCDATETIME());
SELECT CAST(SCOPE_IDENTITY() AS int);";
                    command.Parameters.AddWithValue("@MedicationOrderId", administration.MedicationOrderId);
                    command.Parameters.AddWithValue("@LabId", administration.LabId);
                    command.Parameters.AddWithValue("@PatientId", administration.PatientId);
                    command.Parameters.AddWithValue("@AdministrationDate", administration.AdministrationDate.Date);
                    command.Parameters.AddWithValue("@AdministrationHour", administration.AdministrationHour);
                    command.Parameters.AddWithValue("@Status", administration.Status);
                    command.Parameters.AddWithValue("@Dose", administration.Dose ?? string.Empty);
                    command.Parameters.AddWithValue("@GivenBy", administration.GivenBy ?? string.Empty);
                    command.Parameters.AddWithValue("@CoSign", administration.CoSign ?? string.Empty);
                    command.Parameters.AddWithValue("@Notes", administration.Notes ?? string.Empty);
                    return Convert.ToInt32(await command.ExecuteScalarAsync());
                }
            }
            catch (SqlException ex) when (ex.Number == 2601 || ex.Number == 2627)
            {
                throw new InvalidOperationException("This medication has already been recorded for that date and hour.", ex);
            }
        }

        private static void AddOrderParameters(SqlCommand command, MedicationChartOrderDto order)
        {
            command.Parameters.AddWithValue("@LabId", order.LabId);
            command.Parameters.AddWithValue("@PatientId", order.PatientId);
            command.Parameters.AddWithValue("@MedicationType", order.MedicationType);
            command.Parameters.AddWithValue("@MedicationName", order.MedicationName);
            command.Parameters.AddWithValue("@Strength", order.Strength);
            command.Parameters.AddWithValue("@Route", order.Route);
            command.Parameters.AddWithValue("@Frequency", order.Frequency);
            command.Parameters.AddWithValue("@MaximumDose", order.MaximumDose);
            command.Parameters.AddWithValue("@Indication", order.Indication);
            command.Parameters.AddWithValue("@PrescriberName", order.PrescriberName);
            command.Parameters.AddWithValue("@PrescriberSignature", order.PrescriberSignature);
            command.Parameters.AddWithValue("@StartDate", order.StartDate.Date);
            command.Parameters.AddWithValue("@EndDate", (object?)order.EndDate?.Date ?? DBNull.Value);
        }

        private static MedicationChartOrderDto MapOrder(SqlDataReader reader)
        {
            return new MedicationChartOrderDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                LabId = reader.GetInt32(reader.GetOrdinal("LabId")),
                PatientId = reader.GetInt32(reader.GetOrdinal("PatientId")),
                MedicationType = reader.GetString(reader.GetOrdinal("MedicationType")),
                MedicationName = reader.GetString(reader.GetOrdinal("MedicationName")),
                Strength = reader.GetString(reader.GetOrdinal("Strength")),
                Route = reader.GetString(reader.GetOrdinal("Route")),
                Frequency = reader.GetString(reader.GetOrdinal("Frequency")),
                MaximumDose = reader.GetString(reader.GetOrdinal("MaximumDose")),
                Indication = reader.GetString(reader.GetOrdinal("Indication")),
                PrescriberName = reader.GetString(reader.GetOrdinal("PrescriberName")),
                PrescriberSignature = reader.GetString(reader.GetOrdinal("PrescriberSignature")),
                StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                EndDate = reader.IsDBNull(reader.GetOrdinal("EndDate")) ? null : reader.GetDateTime(reader.GetOrdinal("EndDate")),
                Status = reader.GetString(reader.GetOrdinal("Status")),
                DiscontinuedAt = reader.IsDBNull(reader.GetOrdinal("DiscontinuedAt")) ? null : reader.GetDateTime(reader.GetOrdinal("DiscontinuedAt")),
                DiscontinuedBy = reader.IsDBNull(reader.GetOrdinal("DiscontinuedBy")) ? null : reader.GetString(reader.GetOrdinal("DiscontinuedBy")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                UpdatedAt = reader.GetDateTime(reader.GetOrdinal("UpdatedAt"))
            };
        }

        private static MedicationChartAdministrationDto MapAdministration(SqlDataReader reader)
        {
            return new MedicationChartAdministrationDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                MedicationOrderId = reader.GetInt32(reader.GetOrdinal("MedicationOrderId")),
                LabId = reader.GetInt32(reader.GetOrdinal("LabId")),
                PatientId = reader.GetInt32(reader.GetOrdinal("PatientId")),
                AdministrationDate = reader.GetDateTime(reader.GetOrdinal("AdministrationDate")),
                AdministrationHour = reader.GetByte(reader.GetOrdinal("AdministrationHour")),
                Status = reader.GetString(reader.GetOrdinal("Status")),
                Dose = reader.GetString(reader.GetOrdinal("Dose")),
                GivenBy = reader.GetString(reader.GetOrdinal("GivenBy")),
                CoSign = reader.GetString(reader.GetOrdinal("CoSign")),
                Notes = reader.GetString(reader.GetOrdinal("Notes")),
                AdministeredAt = reader.GetDateTime(reader.GetOrdinal("AdministeredAt"))
            };
        }
    }
}
