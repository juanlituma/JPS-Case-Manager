// Forms/MainForm.cs  ── DIAGNOSTIC VERSION
//
// LoadCasesAsync() is temporarily replaced with LoadTestData() which injects
// 3 hard-coded rows the instant the form opens.  No server, no async, no network.
//
// If the 3 test rows appear  → grid is fine; the bug is in the API path.
// If they still don't appear → grid itself is broken (layout / covering panel).
//
// Once confirmed working, restore LoadCasesAsync() for production use.

using JPSCaseManager.Services;

namespace JPSCaseManager.Forms;

public partial class MainForm : Form
{
    public MainForm()
    {
        InitializeComponent();
        SetupControls();

        Text = $"JPS Case Management  —  {AppSession.CurrentEmployee?.DisplayName ?? ""}";
        lblUser.Text = $"  Logged in as: {AppSession.CurrentEmployee?.DisplayName} | {AppSession.CurrentEmployee?.EmployeeNumber}";

        // Load Cases
        _ = LoadCasesAsync();

        // Call test loader immediately — no Shown event, no async, no server.
        //LoadTestData();
    }

    // ── Grid setup ───────────────────────────────────────────────────────────

    private void SetupControls()
    {
        grid.DataSource = null;
        grid.Columns.Clear();
        grid.AutoGenerateColumns = false;
        grid.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None;

        grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "colId", HeaderText = "ID", Width = 50 });
        grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "colTitle", HeaderText = "Title", Width = 210 });
        grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "colStatus", HeaderText = "Status", Width = 110 });
        grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "colCreatedBy", HeaderText = "Created By", Width = 120 });
        grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "colAssignedTo", HeaderText = "Assigned To", Width = 120 });
        grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "colDescription", HeaderText = "Description", Width = 280 });
        grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "colUpdatedAt", HeaderText = "Last Updated", Width = 130 });

        grid.Columns["colUpdatedAt"].AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill;

        if (cboStatus.Items.Count > 0 && cboStatus.SelectedIndex < 0)
            cboStatus.SelectedIndex = 0;
    }

    // ── DIAGNOSTIC: hard-coded sample data (replaces API call) ───────────────

    //private void LoadTestData()
    //{
    //    // Confirm grid state before adding rows.
    //    MessageBox.Show(
    //        $"Columns in grid : {grid.Columns.Count}\n" +
    //        $"Grid visible     : {grid.Visible}\n" +
    //        $"Grid size        : {grid.Width} x {grid.Height}\n" +
    //        $"DataSource null  : {grid.DataSource == null}",
    //        "DIAGNOSTIC — before Rows.Add");

    //    grid.Rows.Clear();

    //    grid.Rows.Add("1", "Robbery at Main St",  "Open",        "3", "—", "Suspect fled north on foot", "11/05/2026 09:00");
    //    grid.Rows.Add("2", "Traffic Accident",     "In Progress", "5", "2", "Two vehicles, minor injuries", "11/05/2026 10:30");
    //    grid.Rows.Add("3", "Noise Complaint",      "Resolved",    "",  "4", "Resolved on scene",           "11/05/2026 11:15");

    //    lblCount.Text = "Showing 3 of 3 cases (TEST DATA)   ";

    //    // Confirm grid state after adding rows.
    //    MessageBox.Show(
    //        $"Rows in grid : {grid.Rows.Count}\n" +
    //        $"Grid visible : {grid.Visible}\n" +
    //        $"Grid size    : {grid.Width} x {grid.Height}",
    //        "DIAGNOSTIC — after Rows.Add");
    //}

    // ── Event Handlers ───────────────────────────────────────────────────────

    private void btnSearch_Click(object sender, EventArgs e) => _ = LoadCasesAsync();
    private void btnRefresh_Click(object sender, EventArgs e) => _ = LoadCasesAsync();
    private void btnNewCase_Click(object sender, EventArgs e) => OpenCaseDetail(null);
    private void btnEditCase_Click(object sender, EventArgs e) => _ = OpenSelectedCaseAsync();

    private void txtSearch_KeyDown(object sender, KeyEventArgs e)
    {
        if (e.KeyCode == Keys.Enter) _ = LoadCasesAsync();
    }

    private void grid_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
    {
        if (e.RowIndex >= 0) _ = OpenSelectedCaseAsync();
    }

    private void btnLogout_Click(object sender, EventArgs e)
    {
        AppSession.Clear();
        Close();   // LoginForm.FormClosed handler re-shows the login screen automatically
    }

    // ── Real load (Search / Refresh buttons call this) ───────────────────────

    private async Task LoadCasesAsync()
    {
        var statusFilter = cboStatus.SelectedItem?.ToString() switch
        {
            "Open" => "open",
            "In Progress" => "in_progress",
            "Resolved" => "resolved",
            _ => null
        };
        var searchText = txtSearch.Text.Trim();

        btnSearch.Enabled = false;
        btnRefresh.Enabled = false;
        btnSearch.Text = "…";

        try
        {
            var list = await ApiService.GetCasesAsync(status: statusFilter, search: searchText);

            void Populate()
            {
                grid.Rows.Clear();
                foreach (var c in list.Cases)
                {
                    var updated = DateTime.TryParse(c.UpdatedAt, out var d)
                        ? d.ToString("dd/MM/yyyy HH:mm")
                        : (c.UpdatedAt ?? "");

                    grid.Rows.Add(
                        c.Id.ToString(),
                        c.Title ?? "",
                        c.StatusDisplay,
                        c.CreatedByDisplay,
                        c.AssignedToDisplay,
                        c.Description ?? "",
                        updated
                    );
                }
                lblCount.Text = $"Showing {list.Cases.Count} of {list.Total} cases   ";
            }

            if (InvokeRequired) Invoke(Populate); else Populate();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to load cases:\n{ex.Message}", "Error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            btnSearch.Enabled = true;
            btnRefresh.Enabled = true;
            btnSearch.Text = "Search";
        }
    }

    // ── Open Case Detail ─────────────────────────────────────────────────────

    /// <summary>
    /// Fetch the full case from the API (so all fields are populated, including
    /// delivery_provider, complaint_type, solution, and created_by_name) then open
    /// the detail form.
    /// </summary>
    private async Task OpenSelectedCaseAsync()
    {
        if (grid.SelectedRows.Count == 0) return;

        var row = grid.SelectedRows[0];
        if (!int.TryParse(row.Cells["colId"].Value?.ToString(), out var caseId) || caseId == 0)
            return;

        try
        {
            var caseData = await ApiService.GetCaseAsync(caseId);
            OpenCaseDetail(caseData);
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to load case details:\n{ex.Message}", "Error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void OpenCaseDetail(CaseOut? caseData)
    {
        var detail = new CaseDetailForm(caseData);
        detail.CaseSaved += async () => await LoadCasesAsync();
        detail.ShowDialog(this);
    }

    private static string StatusDisplayToValue(string display) => display switch
    {
        "Open" => "open",
        "In Progress" => "in_progress",
        "Resolved" => "resolved",
        _ => display.ToLower()
    };

    private void cboStatus_SelectedIndexChanged(object sender, EventArgs e) => _ = LoadCasesAsync();
   
}
