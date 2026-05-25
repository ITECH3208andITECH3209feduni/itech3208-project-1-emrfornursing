using System.Collections.Generic;
using System.Threading.Tasks;
using Dapper;
using EMRSimulation.Domain.Dtos;
using EMRSimulation.Infrastructure.Connection;

namespace EMRSimulation.Infrastructure.Repositories
{
    public class PolicyRepository : IPolicyRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;

        public PolicyRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IEnumerable<PolicyDto>> GetPoliciesByLabAsync(int labId, string searchTerm)
        {
            using var connection = await _connectionFactory.CreateAsync();
            string sql = "SELECT Id, LabId, FileName, DisplayName, FileSizeString, UploadedDate FROM Policies WHERE LabId = @LabId";
            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                sql += " AND (DisplayName LIKE '%' + @Search + '%' OR FileName LIKE '%' + @Search + '%')";
            }
            return await connection.QueryAsync<PolicyDto>(sql, new { LabId = labId, Search = searchTerm });
        }

        public async Task<PolicyDto> GetPolicyByIdAsync(int id)
        {
            using var connection = await _connectionFactory.CreateAsync();
            string sql = "SELECT * FROM Policies WHERE Id = @Id";
            return await connection.QueryFirstOrDefaultAsync<PolicyDto>(sql, new { Id = id });
        }

        public async Task SavePolicyAsync(PolicyDto policy)
        {
            using var connection = await _connectionFactory.CreateAsync();
            string sql = @"INSERT INTO Policies (LabId, FileName, DisplayName, FileSizeString, FileData, UploadedDate)
                           VALUES (@LabId, @FileName, @DisplayName, @FileSizeString, @FileData, @UploadedDate)";
            await connection.ExecuteAsync(sql, policy);
        }
    }
}
