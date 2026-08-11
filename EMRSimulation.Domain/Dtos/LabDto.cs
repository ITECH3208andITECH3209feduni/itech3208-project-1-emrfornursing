using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EMRSimulation.Domain.Dtos
{
    public class LabDto
    {
        public int Id { get; set; }
        public string LabName{ get; set; }

        /// <summary>Inactive labs are hidden from the load picker.</summary>
        public bool Active { get; set; }
    }
}
