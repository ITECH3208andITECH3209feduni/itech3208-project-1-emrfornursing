using System;

namespace EMRSimulation.Domain.Dtos
{
    public class PolicyDto
    {
        public int Id { get; set; }
        public int LabId { get; set; }
        public string FileName { get; set; }
        public string DisplayName { get; set; }
        public string FileSizeString { get; set; }
        public byte[] FileData { get; set; }
        public DateTime UploadedDate { get; set; }
    }
}
