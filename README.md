Project Name: EMR For Nursing
-------------------
Group Members: 

Kunal Arora - 30432432 

Owen Gray- 300412725 

Samuel Little - 30399549 

Fahim Faisal Al Nour - 30446828 

Description:

This project continues the development of a custom Electronic Medical Record (EMR) simulator used in undergraduate nursing education. 
The simulator provides a digital environment where nursing students can practise clinical documentation and improve upon digital health competencies.
 
The primary goals of the project are to:

*Improve and expand clinical chart functionality.

*Strengthen data processing capabilities and interface usability.

*Create reusable templates that enable academics to efficiently design and manage simulation scenarios.
 
These improvements aim to ensure the simulator provides effective value to students and teachers and to conform to healthcare governance and practices.




Prerequisites - 

Windows 10/11 or Windows Server
Administrator access
Git

Setup

Install ASP.NET Core Runtime 8 (Hosting Bundle)

Install IIS

Install Visual Studio Community 2022 (64-bit) - during install - select ASP.NET and web development

Install SQL Server Express - - during install -select->Custom>Enable Mixed Mode Authentication> set "sa" account password to "Emrp@ssword123!"

Install SSMS

git clone the repository to desired directory

Create the database - in SSMS right-click Databases > New Database, name it EmrSimulator, OK. The scripts below do not create it for you.

Run Database\EMRSimulatorFULL-spr4.sql - open it in SSMS, select EmrSimulator in the database dropdown, Execute. This builds the schema.

Run Database\sqlusers_and_yearLevels.sql against the same database. 

Logins - student lab123 / lab123, supervisor super / super

If you named the database something other than EmrSimulator, update the connection string in EMRSimulationWebApp\appsettings.json to match.

Configure and run in Visual studio via opening EMRSimulationWebApp.sln file Or run publish via visual studio to IIS

