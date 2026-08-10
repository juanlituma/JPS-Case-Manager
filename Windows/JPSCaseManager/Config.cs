// Config.cs — Application-wide settings
// ⚠️ Change BaseUrl to your server's local IP before running.

namespace JPSCaseManager;

public static class Config
{
    /// <summary>FastAPI backend URL. Change to match your server IP and port.</summary>
    public static string BaseUrl { get; set; } = "http://192.168.66.4:8282";
}
