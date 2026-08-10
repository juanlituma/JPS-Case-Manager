// Program.cs — Application entry point

using JPSCaseManager.Forms;

namespace JPSCaseManager;

internal static class Program
{
    [STAThread]
    static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new LoginForm());
    }
}
