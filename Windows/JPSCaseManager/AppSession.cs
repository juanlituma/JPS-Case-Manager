// AppSession.cs — Holds the logged-in employee's token for the current session.

namespace JPSCaseManager;

public static class AppSession
{
    public static string       Token           { get; set; } = string.Empty;
    public static EmployeeOut? CurrentEmployee { get; set; }

    public static bool IsLoggedIn => !string.IsNullOrEmpty(Token);

    public static void Clear()
    {
        Token           = string.Empty;
        CurrentEmployee = null;
    }
}
