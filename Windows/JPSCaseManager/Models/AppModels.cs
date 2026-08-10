// Models/AppModels.cs — C# data models matching the FastAPI backend schemas.

using Newtonsoft.Json;

namespace JPSCaseManager;

// ─── Employee Auth ────────────────────────────────────────────────────────────
// Windows app logs in as an Employee — completely separate from iOS users.

public class EmployeeLoginRequest
{
    [JsonProperty("username")] public string Username { get; set; } = "";
    [JsonProperty("password")] public string Password { get; set; } = "";
}

public class EmployeeOut
{
    [JsonProperty("id")]              public int     Id             { get; set; }
    [JsonProperty("username")]        public string  Username       { get; set; } = "";
    [JsonProperty("email")]           public string  Email          { get; set; } = "";
    [JsonProperty("full_name")]       public string? FullName       { get; set; }
    [JsonProperty("employee_number")] public string  EmployeeNumber { get; set; } = "";
    [JsonProperty("department")]      public string? Department     { get; set; }
    [JsonProperty("phone")]           public string? Phone          { get; set; }
    [JsonProperty("is_active")]       public bool    IsActive       { get; set; }
    [JsonProperty("created_at")]      public string  CreatedAt      { get; set; } = "";

    public string DisplayName => FullName ?? Username;
}

public class EmployeeToken
{
    [JsonProperty("access_token")] public string      AccessToken { get; set; } = "";
    [JsonProperty("token_type")]   public string      TokenType   { get; set; } = "";
    [JsonProperty("employee")]     public EmployeeOut Employee    { get; set; } = new();
}

// ─── User (iOS accounts) ──────────────────────────────────────────────────────

public class UserOut
{
    [JsonProperty("id")]         public int     Id        { get; set; }
    [JsonProperty("username")]   public string  Username  { get; set; } = "";
    [JsonProperty("email")]      public string  Email     { get; set; } = "";
    [JsonProperty("full_name")]  public string? FullName  { get; set; }
    [JsonProperty("is_active")]  public bool    IsActive  { get; set; }
    [JsonProperty("created_at")] public string  CreatedAt { get; set; } = "";

    public string DisplayName => FullName ?? Username;
}

public class EmployeeListOut
{
    [JsonProperty("total")]     public int             Total     { get; set; }
    [JsonProperty("employees")] public List<EmployeeOut> Employees { get; set; } = new();
}

// ─── Cases ────────────────────────────────────────────────────────────────────

public class CaseOut
{
    [JsonProperty("id")]                       public int     Id                    { get; set; }
    [JsonProperty("title")]                    public string  Title                 { get; set; } = "";
    [JsonProperty("description")]              public string? Description           { get; set; }
    [JsonProperty("solution")]                 public string? Solution              { get; set; }
    [JsonProperty("delivery_provider")]        public string? DeliveryProvider      { get; set; }
    [JsonProperty("complaint_type")]           public string? ComplaintType         { get; set; }
    [JsonProperty("status")]                   public string  Status                { get; set; } = "";
    [JsonProperty("created_by_id")]   public int?    CreatedById   { get; set; }
    [JsonProperty("created_by_name")] public string? CreatedByName { get; set; }
    [JsonProperty("assigned_to_id")]   public int?    AssignedToId   { get; set; }
    [JsonProperty("assigned_to_name")] public string? AssignedToName { get; set; }
    [JsonProperty("created_at")]       public string  CreatedAt      { get; set; } = "";
    [JsonProperty("updated_at")]       public string  UpdatedAt      { get; set; } = "";

    public string StatusDisplay => Status switch
    {
        "open"        => "Open",
        "in_progress" => "In Progress",
        "resolved"    => "Resolved",
        _             => Status
    };

    /// <summary>Best available display name for whoever created this case.</summary>
    public string CreatedByDisplay =>
        !string.IsNullOrWhiteSpace(CreatedByName) ? CreatedByName :
        CreatedById.HasValue ? $"User #{CreatedById}" :
        "Unknown";

    /// <summary>Best available display name for the assigned employee.</summary>
    public string AssignedToDisplay =>
        !string.IsNullOrWhiteSpace(AssignedToName) ? AssignedToName :
        AssignedToId.HasValue ? $"Employee #{AssignedToId}" :
        "—";
}

public class CaseListOut
{
    [JsonProperty("total")] public int           Total { get; set; }
    [JsonProperty("cases")] public List<CaseOut> Cases { get; set; } = new();
}

public class CaseCreate
{
    [JsonProperty("title")]             public string  Title            { get; set; } = "";
    [JsonProperty("description")]       public string? Description      { get; set; }
    [JsonProperty("solution")]          public string? Solution         { get; set; }
    [JsonProperty("delivery_provider")] public string? DeliveryProvider { get; set; }
    [JsonProperty("complaint_type")]    public string? ComplaintType    { get; set; }
    [JsonProperty("assigned_to_id")]    public int?    AssignedToId     { get; set; }
}

public class CaseUpdate
{
    [JsonProperty("title")]             public string? Title            { get; set; }
    [JsonProperty("description")]       public string? Description      { get; set; }
    [JsonProperty("solution")]          public string? Solution         { get; set; }
    [JsonProperty("delivery_provider")] public string? DeliveryProvider { get; set; }
    [JsonProperty("complaint_type")]    public string? ComplaintType    { get; set; }
    [JsonProperty("status")]            public string? Status           { get; set; }
    [JsonProperty("assigned_to_id")]    public int?    AssignedToId     { get; set; }
}

// ─── Error ────────────────────────────────────────────────────────────────────

public class ApiErrorResponse
{
    [JsonProperty("detail")] public string Detail { get; set; } = "Unknown error";
}
