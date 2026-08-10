// Services/ApiService.cs — All HTTP calls to the FastAPI backend.
// Windows app authenticates as an Employee (POST /employees/login),
// completely separate from iOS user accounts (POST /auth/login).

using System.Net.Http.Headers;
using System.Text;
using Newtonsoft.Json;

namespace JPSCaseManager.Services;

public class ApiException : Exception
{
    public ApiException(string message) : base(message) { }
}

public static class ApiService
{
    private static readonly HttpClient _http = new()
    {
        Timeout = TimeSpan.FromSeconds(15)
    };

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static string Url(string path) => $"{Config.BaseUrl}{path}";

    private static StringContent Json(object body) =>
        new(JsonConvert.SerializeObject(body), Encoding.UTF8, "application/json");

    private static void SetAuth(string token) =>
        _http.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", token);

    private static async Task<T> ReadOrThrow<T>(HttpResponseMessage res)
    {
        var raw = await res.Content.ReadAsStringAsync();
        if (!res.IsSuccessStatusCode)
        {
            var err = JsonConvert.DeserializeObject<ApiErrorResponse>(raw);
            throw new ApiException(err?.Detail ?? $"HTTP {(int)res.StatusCode}");
        }
        return JsonConvert.DeserializeObject<T>(raw)
               ?? throw new ApiException("Empty response from server.");
    }

    // ── Employee Auth ─────────────────────────────────────────────────────────

    /// <summary>
    /// Login as an Employee and return an EmployeeToken.
    /// Calls POST /employees/login — separate from the iOS user login endpoint.
    /// Stores the token and employee info in AppSession.
    /// </summary>
    public static async Task<EmployeeToken> LoginAsync(string username, string password)
    {
        var res = await _http.PostAsync(
            Url("/employees/login"),
            Json(new EmployeeLoginRequest { Username = username, Password = password })
        );
        var token = await ReadOrThrow<EmployeeToken>(res);
        AppSession.Token           = token.AccessToken;
        AppSession.CurrentEmployee = token.Employee;
        SetAuth(token.AccessToken);
        return token;
    }

    // ── Cases ─────────────────────────────────────────────────────────────────

    /// <summary>Fetch cases with optional status filter and search keyword.</summary>
    public static async Task<CaseListOut> GetCasesAsync(
        string? status = null,
        string? search = null,
        int skip  = 0,
        int limit = 100)
    {
        SetAuth(AppSession.Token);
        var query = $"?skip={skip}&limit={limit}";
        if (!string.IsNullOrEmpty(status) && status != "All")
            query += $"&status={Uri.EscapeDataString(status)}";

        var res  = await _http.GetAsync(Url($"/cases{query}"));
        var list = await ReadOrThrow<CaseListOut>(res);

        // Client-side keyword filter (title / description)
        if (!string.IsNullOrWhiteSpace(search))
        {
            var kw = search.Trim().ToLowerInvariant();
            list.Cases = list.Cases
                .Where(c => c.Title.ToLowerInvariant().Contains(kw) ||
                            (c.Description?.ToLowerInvariant().Contains(kw) ?? false))
                .ToList();
            list.Total = list.Cases.Count;
        }
        return list;
    }

    /// <summary>Create a new case.</summary>
    public static async Task<CaseOut> CreateCaseAsync(CaseCreate payload)
    {
        SetAuth(AppSession.Token);
        var res = await _http.PostAsync(Url("/cases"), Json(payload));
        return await ReadOrThrow<CaseOut>(res);
    }

    /// <summary>Fetch a single case by ID — returns full detail including all fields.</summary>
    public static async Task<CaseOut> GetCaseAsync(int caseId)
    {
        SetAuth(AppSession.Token);
        var res = await _http.GetAsync(Url($"/cases/{caseId}"));
        return await ReadOrThrow<CaseOut>(res);
    }

    /// <summary>Update an existing case. Only non-null fields are sent.</summary>
    public static async Task<CaseOut> UpdateCaseAsync(int caseId, CaseUpdate payload)
    {
        SetAuth(AppSession.Token);
        var res = await _http.PutAsync(Url($"/cases/{caseId}"), Json(payload));
        return await ReadOrThrow<CaseOut>(res);
    }

    // ── Employees (for Assign-To dropdown) ───────────────────────────────────

    /// <summary>
    /// Return all employees.
    /// Used by CaseDetailForm to populate the "Assign To" dropdown.
    /// Calls GET /employees — requires employee token.
    /// </summary>
    public static async Task<List<EmployeeOut>> GetEmployeesAsync()
    {
        SetAuth(AppSession.Token);
        var res  = await _http.GetAsync(Url("/employees"));
        var list = await ReadOrThrow<EmployeeListOut>(res);
        return list.Employees;
    }
}
