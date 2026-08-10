// Forms/CaseDetailForm.cs — Create / Edit case logic

using JPSCaseManager.Services;

namespace JPSCaseManager.Forms;

public partial class CaseDetailForm : Form
{
    private readonly CaseOut? _existing;
    public event Func<Task>?  CaseSaved;

    public CaseDetailForm(CaseOut? existingCase)
    {
        _existing = existingCase;
        InitializeComponent();

        bool isNew = _existing == null;
        Text           = isNew ? "New Case" : $"Case #{_existing!.Id} — Edit";
        btnSave.Text   = isNew ? "Create Case" : "Save Changes";

        if (!isNew)
        {
            lblCaseInfo.Text    = $"Case ID: #{_existing!.Id}   |   Updated: {FormatDate(_existing.UpdatedAt)}";
            lblCaseInfo.Visible = true;

            // Show the Created By field
            lblCreatedByField.Visible = true;
            txtCreatedBy.Text         = _existing.CreatedByDisplay;
            txtCreatedBy.Visible      = true;

            txtTitle.Text = _existing.Title;
            txtDescription.Text = _existing.Description ?? "";
            txtSolution.Text    = _existing.Solution ?? "";
            cboStatus.SelectedItem = _existing.Status;
            if (cboStatus.SelectedIndex < 0) cboStatus.SelectedIndex = 0;

            // Pre-select Delivery Provider — match by the display string in the combo box
            var deliveryDisplay = DeliveryApiToDisplay(_existing.DeliveryProvider);
            int deliveryIdx = cboDelivery.Items.IndexOf(deliveryDisplay);
            cboDelivery.SelectedIndex = deliveryIdx >= 0 ? deliveryIdx : 0;

            // Pre-select Complaint Type — match by the display string in the combo box
            var complaintDisplay = ComplaintApiToDisplay(_existing.ComplaintType);
            int complaintIdx = cboComplaint.Items.IndexOf(complaintDisplay);
            cboComplaint.SelectedIndex = complaintIdx >= 0 ? complaintIdx : 0;
        }

        _ = LoadEmployeesAsync();
    }

    // ── Event Handlers ───────────────────────────────────────────────────────

    private void btnCancel_Click(object sender, EventArgs e) => Close();
    private async void btnSave_Click(object sender, EventArgs e) => await SaveAsync();

    // ── Load Employees for Assign-To Dropdown ────────────────────────────────

    private async Task LoadEmployeesAsync()
    {
        try
        {
            var employees = await ApiService.GetEmployeesAsync();
            cboAssigned.Items.Clear();
            cboAssigned.Items.Add(new EmployeeItem(null, "— Unassigned —"));
            foreach (var e in employees)
                cboAssigned.Items.Add(new EmployeeItem(e.Id, e.DisplayName));

            if (_existing?.AssignedToId != null)
            {
                foreach (EmployeeItem item in cboAssigned.Items)
                    if (item.EmployeeId == _existing.AssignedToId)
                    { cboAssigned.SelectedItem = item; break; }
            }
            if (cboAssigned.SelectedIndex < 0) cboAssigned.SelectedIndex = 0;
        }
        catch
        {
            cboAssigned.Items.Add(new EmployeeItem(null, "— (could not load employees) —"));
            cboAssigned.SelectedIndex = 0;
        }
    }

    // ── Save Logic ───────────────────────────────────────────────────────────

    private async Task SaveAsync()
    {
        if (string.IsNullOrWhiteSpace(txtTitle.Text))
        {
            ShowInfo("Title is required.", Color.Crimson);
            return;
        }

        btnSave.Enabled = false;
        btnSave.Text    = "Saving…";

        var assignedId = (cboAssigned.SelectedItem as EmployeeItem)?.EmployeeId;
        var desc       = string.IsNullOrWhiteSpace(txtDescription.Text) ? null : txtDescription.Text.Trim();
        var solution   = string.IsNullOrWhiteSpace(txtSolution.Text)    ? null : txtSolution.Text.Trim();
        var delivery   = DeliveryDisplayToApi(cboDelivery.SelectedItem?.ToString());
        var complaint  = ComplaintDisplayToApi(cboComplaint.SelectedItem?.ToString());

        try
        {
            if (_existing == null)
            {
                await ApiService.CreateCaseAsync(new CaseCreate
                {
                    Title            = txtTitle.Text.Trim(),
                    Description      = desc,
                    Solution         = solution,
                    DeliveryProvider = delivery,
                    ComplaintType    = complaint,
                    AssignedToId     = assignedId
                });
                ShowInfo("✔  Case created. iOS app will be notified shortly.", Color.FromArgb(39, 130, 60));
            }
            else
            {
                await ApiService.UpdateCaseAsync(_existing.Id, new CaseUpdate
                {
                    Title            = txtTitle.Text.Trim(),
                    Description      = desc,
                    Solution         = solution,
                    DeliveryProvider = delivery,
                    ComplaintType    = complaint,
                    Status           = cboStatus.SelectedItem?.ToString(),
                    AssignedToId     = assignedId
                });
                ShowInfo("✔  Changes saved. iOS app will be notified shortly.", Color.FromArgb(39, 130, 60));
            }

            if (CaseSaved != null) await CaseSaved.Invoke();
            await Task.Delay(1200);
            Close();
        }
        catch (Exception ex)
        {
            ShowInfo($"Error: {ex.Message}", Color.Crimson);
            btnSave.Enabled = true;
            btnSave.Text    = _existing == null ? "Create Case" : "Save Changes";
        }
    }

    private void ShowInfo(string msg, Color color)
    {
        lblInfo.Text      = msg;
        lblInfo.ForeColor = color;
        lblInfo.Visible   = true;
    }

    private static string FormatDate(string iso) =>
        DateTime.TryParse(iso, out var dt) ? dt.ToString("dd/MM/yyyy HH:mm") + " ET" : iso;

    // ── Delivery Provider mapping ────────────────────────────────────────────
    // API values match display names directly (Uber, DoorDash, GrabHub, Self Delivery)
    private static string? DeliveryDisplayToApi(string? display) => display switch
    {
        "Uber"          => "Uber",
        "DoorDash"      => "DoorDash",
        "GrabHub"       => "GrabHub",
        "Self Delivery" => "Self Delivery",
        _               => null
    };

    private static string DeliveryApiToDisplay(string? api) => api switch
    {
        "Uber"          => "Uber",
        "DoorDash"      => "DoorDash",
        "GrabHub"       => "GrabHub",
        "Self Delivery" => "Self Delivery",
        _               => "— None —"
    };

    // ── Complaint Type mapping ───────────────────────────────────────────────
    private static string? ComplaintDisplayToApi(string? display) => display switch
    {
        "Not Receive Food"    => "not_receive_food",
        "Food Bad Quality"    => "food_bad_quality",
        "Missing Item"        => "missing_item",
        "Received Wrong Order"=> "received_wrong_order",
        _                     => null
    };

    private static string ComplaintApiToDisplay(string? api) => api switch
    {
        "not_receive_food"    => "Not Receive Food",
        "food_bad_quality"    => "Food Bad Quality",
        "missing_item"        => "Missing Item",
        "received_wrong_order"=> "Received Wrong Order",
        _                     => "— None —"
    };

    // ── Inner class: ComboBox item carrying nullable employee ID ─────────────
    private sealed class EmployeeItem
    {
        public int? EmployeeId { get; }
        private readonly string _display;
        public EmployeeItem(int? id, string display) { EmployeeId = id; _display = display; }
        public override string ToString() => _display;
    }
}
