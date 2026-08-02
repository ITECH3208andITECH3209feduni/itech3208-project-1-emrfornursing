using EMRSimulation.Application.Interfaces;
using EMRSimulation.Domain.Dtos;
using EMRSimulation.Infrastructure.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace EMRSimulation.Infrastructure.Repositories
{
    /// <summary>
    /// Sprint 3, Requirement 1 - global module repository data access.
    ///
    /// Follows the existing PatientRepository conventions: stored procedure
    /// names as literals, SqlParameter per argument, manual reader mapping.
    /// </summary>
    public class ModuleRepository : IModuleRepository
    {
        private readonly IDbConnectionFactory _dbConnectionFactory;

        public ModuleRepository(IDbConnectionFactory dbConnectionFactory)
        {
            _dbConnectionFactory = dbConnectionFactory;
        }

        /* ------------------------------------------------------------------
           helpers
           ------------------------------------------------------------------ */

        private static string? Str(SqlDataReader r, string col)
            => r.IsDBNull(r.GetOrdinal(col)) ? null : r.GetString(r.GetOrdinal(col));

        private static int? NullableInt(SqlDataReader r, string col)
            => r.IsDBNull(r.GetOrdinal(col)) ? null : r.GetInt32(r.GetOrdinal(col));

        private static DateTime? NullableDate(SqlDataReader r, string col)
            => r.IsDBNull(r.GetOrdinal(col)) ? null : r.GetDateTime(r.GetOrdinal(col));

        private async Task<int> ExecuteScalarIntAsync(string procName, Action<SqlCommand> addParams)
        {
            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandText = procName;
                command.CommandType = CommandType.StoredProcedure;
                addParams(command);

                var result = await command.ExecuteScalarAsync();
                if (result == null || result == DBNull.Value) return 0;
                return Convert.ToInt32(result);
            }
        }

        /* ------------------------------------------------------------------
           year levels
           ------------------------------------------------------------------ */

        public async Task<IEnumerable<YearLevelDto>> GetYearLevelsAsync(bool includeInactive = false)
        {
            var list = new List<YearLevelDto>();

            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandText = "GetYearLevels";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@IncludeInactive", includeInactive));

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        list.Add(new YearLevelDto
                        {
                            Id            = reader.GetInt32(reader.GetOrdinal("Id")),
                            YearLevelName = Str(reader, "YearLevelName"),
                            SortOrder     = reader.GetInt32(reader.GetOrdinal("SortOrder")),
                            Active        = reader.GetBoolean(reader.GetOrdinal("Active")),
                            CreatedDate   = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                            UnitCount     = reader.GetInt32(reader.GetOrdinal("UnitCount"))
                        });
                    }
                }
            }

            return list;
        }

        public Task<int> InsertYearLevelAsync(YearLevelDto dto)
            => ExecuteScalarIntAsync("InsertYearLevel", cmd =>
            {
                cmd.Parameters.Add(new SqlParameter("@YearLevelName", (object?)dto.YearLevelName ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@SortOrder", dto.SortOrder));
            });

        public Task<int> UpdateYearLevelAsync(YearLevelDto dto)
            => ExecuteScalarIntAsync("UpdateYearLevel", cmd =>
            {
                cmd.Parameters.Add(new SqlParameter("@Id", dto.Id));
                cmd.Parameters.Add(new SqlParameter("@YearLevelName", (object?)dto.YearLevelName ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@SortOrder", dto.SortOrder));
                cmd.Parameters.Add(new SqlParameter("@Active", dto.Active));
            });

        /* ------------------------------------------------------------------
           units
           ------------------------------------------------------------------ */

        public async Task<IEnumerable<UnitDto>> GetUnitsAsync(int yearLevelId = 0, bool includeInactive = false)
        {
            var list = new List<UnitDto>();

            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandText = "GetUnits";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@YearLevelId", yearLevelId));
                command.Parameters.Add(new SqlParameter("@IncludeInactive", includeInactive));

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        list.Add(new UnitDto
                        {
                            Id            = reader.GetInt32(reader.GetOrdinal("Id")),
                            YearLevelId   = reader.GetInt32(reader.GetOrdinal("YearLevelId")),
                            YearLevelName = Str(reader, "YearLevelName"),
                            UnitCode      = Str(reader, "UnitCode"),
                            UnitName      = Str(reader, "UnitName"),
                            SortOrder     = reader.GetInt32(reader.GetOrdinal("SortOrder")),
                            Active        = reader.GetBoolean(reader.GetOrdinal("Active")),
                            CreatedDate   = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                            ModuleCount   = reader.GetInt32(reader.GetOrdinal("ModuleCount"))
                        });
                    }
                }
            }

            return list;
        }

        public Task<int> InsertUnitAsync(UnitDto dto)
            => ExecuteScalarIntAsync("InsertUnit", cmd =>
            {
                cmd.Parameters.Add(new SqlParameter("@YearLevelId", dto.YearLevelId));
                cmd.Parameters.Add(new SqlParameter("@UnitCode", (object?)dto.UnitCode ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@UnitName", (object?)dto.UnitName ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@SortOrder", dto.SortOrder));
            });

        public Task<int> UpdateUnitAsync(UnitDto dto)
            => ExecuteScalarIntAsync("UpdateUnit", cmd =>
            {
                cmd.Parameters.Add(new SqlParameter("@Id", dto.Id));
                cmd.Parameters.Add(new SqlParameter("@YearLevelId", dto.YearLevelId));
                cmd.Parameters.Add(new SqlParameter("@UnitCode", (object?)dto.UnitCode ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@UnitName", (object?)dto.UnitName ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@SortOrder", dto.SortOrder));
                cmd.Parameters.Add(new SqlParameter("@Active", dto.Active));
            });

        /* ------------------------------------------------------------------
           modules
           ------------------------------------------------------------------ */

        private static ModuleDto ReadModule(SqlDataReader reader) => new ModuleDto
        {
            Id                    = reader.GetInt32(reader.GetOrdinal("Id")),
            UnitId                = reader.GetInt32(reader.GetOrdinal("UnitId")),
            UnitCode              = Str(reader, "UnitCode"),
            UnitName              = Str(reader, "UnitName"),
            YearLevelId           = reader.GetInt32(reader.GetOrdinal("YearLevelId")),
            YearLevelName         = Str(reader, "YearLevelName"),
            ModuleName            = Str(reader, "ModuleName"),
            Description           = Str(reader, "Description"),
            SortOrder             = reader.GetInt32(reader.GetOrdinal("SortOrder")),
            Active                = reader.GetBoolean(reader.GetOrdinal("Active")),
            CreatedBySupervisorId = NullableInt(reader, "CreatedBySupervisorId"),
            CreatedDate           = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
            UpdatedDate           = NullableDate(reader, "UpdatedDate"),
            PatientCount          = reader.GetInt32(reader.GetOrdinal("PatientCount"))
        };

        public async Task<IEnumerable<ModuleDto>> GetModulesAsync(int yearLevelId = 0, int unitId = 0,
                                                                  string? searchTerm = null,
                                                                  bool includeInactive = false)
        {
            var list = new List<ModuleDto>();

            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandText = "GetModules";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@YearLevelId", yearLevelId));
                command.Parameters.Add(new SqlParameter("@UnitId", unitId));
                command.Parameters.Add(new SqlParameter("@SearchTerm", (object?)searchTerm ?? DBNull.Value));
                command.Parameters.Add(new SqlParameter("@IncludeInactive", includeInactive));

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync()) list.Add(ReadModule(reader));
                }
            }

            return list;
        }

        public async Task<ModuleDto?> GetModuleByIdAsync(int moduleId)
        {
            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandText = "GetModuleById";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@ModuleId", moduleId));

                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync()) return ReadModule(reader);
                }
            }

            return null;
        }

        public Task<int> InsertModuleAsync(ModuleDto dto, int? createdBySupervisorId, bool createBlankPatient = true)
            => ExecuteScalarIntAsync("InsertModule", cmd =>
            {
                cmd.Parameters.Add(new SqlParameter("@UnitId", dto.UnitId));
                cmd.Parameters.Add(new SqlParameter("@ModuleName", (object?)dto.ModuleName ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@Description", (object?)dto.Description ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@CreatedBySupervisorId", (object?)createdBySupervisorId ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@SortOrder", dto.SortOrder));
                cmd.Parameters.Add(new SqlParameter("@CreateBlankPatient", createBlankPatient));
            });

        public Task<int> UpdateModuleAsync(ModuleDto dto)
            => ExecuteScalarIntAsync("UpdateModule", cmd =>
            {
                cmd.Parameters.Add(new SqlParameter("@Id", dto.Id));
                cmd.Parameters.Add(new SqlParameter("@ModuleName", (object?)dto.ModuleName ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@Description", (object?)dto.Description ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@UnitId", dto.UnitId));
                cmd.Parameters.Add(new SqlParameter("@SortOrder", dto.SortOrder));
                cmd.Parameters.Add(new SqlParameter("@Active", dto.Active));
            });

        public Task<int> CopyModuleAsync(int sourceModuleId, string newModuleName, int targetUnitId,
                                         string? description, int? createdBySupervisorId)
            => ExecuteScalarIntAsync("CopyModule", cmd =>
            {
                cmd.Parameters.Add(new SqlParameter("@SourceModuleId", sourceModuleId));
                cmd.Parameters.Add(new SqlParameter("@NewModuleName", newModuleName));
                cmd.Parameters.Add(new SqlParameter("@TargetUnitId", targetUnitId));
                cmd.Parameters.Add(new SqlParameter("@Description", (object?)description ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@CreatedBySupervisorId", (object?)createdBySupervisorId ?? DBNull.Value));
            });

        public async Task<IEnumerable<(string TableName, int RowsDeleted)>> DeleteModuleAsync(int moduleId)
        {
            var cleared = new List<(string, int)>();

            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandText = "DeleteModule";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@ModuleId", moduleId));

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        cleared.Add((
                            reader.GetString(reader.GetOrdinal("TableName")),
                            reader.GetInt32(reader.GetOrdinal("RowsDeleted"))
                        ));
                    }
                }
            }

            return cleared;
        }

        /* ------------------------------------------------------------------
           module contents
           ------------------------------------------------------------------ */

        public async Task<IEnumerable<PatientDto>> GetPatientsByModuleAsync(int moduleId)
        {
            var patients = new List<PatientDto>();

            using (var connection = await _dbConnectionFactory.CreateAsync())
            using (var command = (SqlCommand)connection.CreateCommand())
            {
                command.CommandText = "GetPatientsByModule";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@ModuleId", moduleId));

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        patients.Add(new PatientDto
                        {
                            Id          = reader.GetInt32(reader.GetOrdinal("Id")),
                            // Module patients carry LabId 0 rather than NULL, but read
                            // defensively so a hand-edited row cannot crash the page.
                            LabId       = reader.IsDBNull(reader.GetOrdinal("LabId"))
                                              ? 0 : reader.GetInt32(reader.GetOrdinal("LabId")),
                            ModuleId    = NullableInt(reader, "ModuleId"),
                            FirstName   = Str(reader, "FirstName"),
                            LastName    = Str(reader, "LastName"),
                            DateOfBirth = NullableDate(reader, "DateOfBirth"),
                            Gender      = Str(reader, "Gender"),
                            Address     = Str(reader, "Address"),
                            AdmitDate   = NullableDate(reader, "AdmitDate"),
                            Weight      = Str(reader, "Weight"),
                            Height      = Str(reader, "Height"),
                            Age         = Str(reader, "Age"),
                            Allergy     = Str(reader, "Allergy"),
                            Intolerance = Str(reader, "Intolerance"),
                            Alerts      = Str(reader, "Alerts"),
                            UriNumber   = Str(reader, "UriNumber"),
                            Alert       = NullableInt(reader, "Alert")
                        });
                    }
                }
            }

            return patients;
        }
    }
}
