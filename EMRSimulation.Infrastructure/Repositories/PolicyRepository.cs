using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using EMRSimulation.Domain.Dtos;
using EMRSimulation.Infrastructure.Connection;

namespace EMRSimulation.Infrastructure.Repositories
{
    public class PolicyRepository : IPolicyRepository
    {
        private readonly IDbConnectionFactory _dbConnectionFactory;

        public PolicyRepository(IDbConnectionFactory dbConnectionFactory)
        {
            _dbConnectionFactory = dbConnectionFactory;
        }

        public async Task<IEnumerable<PolicyDto>> GetPoliciesByLabAsync(int labId, string searchTerm)
        {
            var policies = new List<PolicyDto>();

            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandText = "GetPoliciesByLab";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@LabId", labId));
                command.Parameters.Add(new SqlParameter("@Search", (object)searchTerm ?? string.Empty));

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        policies.Add(new PolicyDto
                        {
                            Id = reader.GetInt32(reader.GetOrdinal("Id")),
                            LabId = reader.GetInt32(reader.GetOrdinal("LabId")),
                            FileName = reader.IsDBNull(reader.GetOrdinal("FileName")) ? null : reader.GetString(reader.GetOrdinal("FileName")),
                            DisplayName = reader.IsDBNull(reader.GetOrdinal("DisplayName")) ? null : reader.GetString(reader.GetOrdinal("DisplayName")),
                            FileSizeString = reader.IsDBNull(reader.GetOrdinal("FileSizeString")) ? null : reader.GetString(reader.GetOrdinal("FileSizeString")),
                            UploadedDate = reader.GetDateTime(reader.GetOrdinal("UploadedDate"))
                        });
                    }
                }
            }

            return policies;
        }

        public async Task<PolicyDto> GetPolicyByIdAsync(int id)
        {
            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandText = "GetPolicyById";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@Id", id));

                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        return new PolicyDto
                        {
                            Id = reader.GetInt32(reader.GetOrdinal("Id")),
                            LabId = reader.GetInt32(reader.GetOrdinal("LabId")),
                            FileName = reader.IsDBNull(reader.GetOrdinal("FileName")) ? null : reader.GetString(reader.GetOrdinal("FileName")),
                            DisplayName = reader.IsDBNull(reader.GetOrdinal("DisplayName")) ? null : reader.GetString(reader.GetOrdinal("DisplayName")),
                            FileSizeString = reader.IsDBNull(reader.GetOrdinal("FileSizeString")) ? null : reader.GetString(reader.GetOrdinal("FileSizeString")),
                            FileData = reader.IsDBNull(reader.GetOrdinal("FileData")) ? null : (byte[])reader["FileData"],
                            UploadedDate = reader.GetDateTime(reader.GetOrdinal("UploadedDate"))
                        };
                    }
                }
            }

            return null;
        }

        public async Task SavePolicyAsync(PolicyDto policy)
        {
            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandText = "InsertPolicy";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@LabId", policy.LabId));
                command.Parameters.Add(new SqlParameter("@FileName", (object)policy.FileName ?? DBNull.Value));
                command.Parameters.Add(new SqlParameter("@DisplayName", (object)policy.DisplayName ?? DBNull.Value));
                command.Parameters.Add(new SqlParameter("@FileSizeString", (object)policy.FileSizeString ?? DBNull.Value));
                command.Parameters.Add(new SqlParameter("@FileData", (object)policy.FileData ?? DBNull.Value));
                command.Parameters.Add(new SqlParameter("@UploadedDate", policy.UploadedDate));
                await command.ExecuteNonQueryAsync();
            }
        }
    }
}
