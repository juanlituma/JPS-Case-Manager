// Forms/CaseDetailForm.Designer.cs — Designer-generated UI for CaseDetailForm

namespace JPSCaseManager.Forms;

partial class CaseDetailForm
{
    private System.ComponentModel.IContainer components = null;

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
            components.Dispose();
        base.Dispose(disposing);
    }

    private void InitializeComponent()
    {
        System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(CaseDetailForm));
        lblCaseInfo = new Label();
        lblCreatedByField = new Label();
        txtCreatedBy = new TextBox();
        lblTitleField = new Label();
        txtTitle = new TextBox();
        lblDescField = new Label();
        txtDescription = new TextBox();
        lblSolutionField = new Label();
        txtSolution = new TextBox();
        lblStatusField = new Label();
        cboStatus = new ComboBox();
        lblAssignField = new Label();
        cboAssigned = new ComboBox();
        lblDeliveryField = new Label();
        cboDelivery = new ComboBox();
        lblComplaintField = new Label();
        cboComplaint = new ComboBox();
        lblNotify = new Label();
        lblInfo = new Label();
        btnSave = new Button();
        btnCancel = new Button();
        SuspendLayout();
        // 
        // lblCaseInfo
        // 
        lblCaseInfo.Font = new Font("Segoe UI", 8.5F);
        lblCaseInfo.ForeColor = Color.Gray;
        lblCaseInfo.Location = new Point(28, 18);
        lblCaseInfo.Name = "lblCaseInfo";
        lblCaseInfo.Size = new Size(524, 20);
        lblCaseInfo.TabIndex = 0;
        lblCaseInfo.Visible = false;
        // 
        // lblCreatedByField
        // 
        lblCreatedByField.AutoSize = true;
        lblCreatedByField.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblCreatedByField.ForeColor = Color.FromArgb(70, 70, 70);
        lblCreatedByField.Location = new Point(28, 44);
        lblCreatedByField.Name = "lblCreatedByField";
        lblCreatedByField.Size = new Size(85, 20);
        lblCreatedByField.TabIndex = 1;
        lblCreatedByField.Text = "Created By";
        lblCreatedByField.Visible = false;
        // 
        // txtCreatedBy
        // 
        txtCreatedBy.BackColor = Color.FromArgb(235, 236, 240);
        txtCreatedBy.BorderStyle = BorderStyle.FixedSingle;
        txtCreatedBy.Font = new Font("Segoe UI", 10F);
        txtCreatedBy.ForeColor = Color.FromArgb(60, 60, 60);
        txtCreatedBy.Location = new Point(28, 64);
        txtCreatedBy.Name = "txtCreatedBy";
        txtCreatedBy.ReadOnly = true;
        txtCreatedBy.Size = new Size(300, 30);
        txtCreatedBy.TabIndex = 2;
        txtCreatedBy.Visible = false;
        // 
        // lblTitleField
        // 
        lblTitleField.AutoSize = true;
        lblTitleField.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblTitleField.ForeColor = Color.FromArgb(70, 70, 70);
        lblTitleField.Location = new Point(28, 96);
        lblTitleField.Name = "lblTitleField";
        lblTitleField.Size = new Size(51, 20);
        lblTitleField.TabIndex = 3;
        lblTitleField.Text = "Title *";
        // 
        // txtTitle
        // 
        txtTitle.BackColor = Color.FromArgb(245, 246, 248);
        txtTitle.BorderStyle = BorderStyle.FixedSingle;
        txtTitle.Font = new Font("Segoe UI", 10F);
        txtTitle.Location = new Point(28, 118);
        txtTitle.Name = "txtTitle";
        txtTitle.Size = new Size(524, 30);
        txtTitle.TabIndex = 4;
        // 
        // lblDescField
        // 
        lblDescField.AutoSize = true;
        lblDescField.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblDescField.ForeColor = Color.FromArgb(70, 70, 70);
        lblDescField.Location = new Point(28, 162);
        lblDescField.Name = "lblDescField";
        lblDescField.Size = new Size(89, 20);
        lblDescField.TabIndex = 5;
        lblDescField.Text = "Description";
        // 
        // txtDescription
        // 
        txtDescription.BackColor = Color.FromArgb(245, 246, 248);
        txtDescription.BorderStyle = BorderStyle.FixedSingle;
        txtDescription.Font = new Font("Segoe UI", 10F);
        txtDescription.Location = new Point(28, 184);
        txtDescription.Multiline = true;
        txtDescription.Name = "txtDescription";
        txtDescription.ScrollBars = ScrollBars.Vertical;
        txtDescription.Size = new Size(524, 90);
        txtDescription.TabIndex = 6;
        // 
        // lblSolutionField
        // 
        lblSolutionField.AutoSize = true;
        lblSolutionField.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblSolutionField.ForeColor = Color.FromArgb(70, 70, 70);
        lblSolutionField.Location = new Point(28, 290);
        lblSolutionField.Name = "lblSolutionField";
        lblSolutionField.Size = new Size(166, 20);
        lblSolutionField.TabIndex = 7;
        lblSolutionField.Text = "Solution (agent notes)";
        // 
        // txtSolution
        // 
        txtSolution.BackColor = Color.FromArgb(245, 246, 248);
        txtSolution.BorderStyle = BorderStyle.FixedSingle;
        txtSolution.Font = new Font("Segoe UI", 10F);
        txtSolution.Location = new Point(28, 312);
        txtSolution.Multiline = true;
        txtSolution.Name = "txtSolution";
        txtSolution.ScrollBars = ScrollBars.Vertical;
        txtSolution.Size = new Size(524, 80);
        txtSolution.TabIndex = 8;
        // 
        // lblStatusField
        // 
        lblStatusField.AutoSize = true;
        lblStatusField.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblStatusField.ForeColor = Color.FromArgb(70, 70, 70);
        lblStatusField.Location = new Point(28, 410);
        lblStatusField.Name = "lblStatusField";
        lblStatusField.Size = new Size(53, 20);
        lblStatusField.TabIndex = 9;
        lblStatusField.Text = "Status";
        // 
        // cboStatus
        // 
        cboStatus.DropDownStyle = ComboBoxStyle.DropDownList;
        cboStatus.Font = new Font("Segoe UI", 10F);
        cboStatus.Items.AddRange(new object[] { "open", "in_progress", "resolved" });
        cboStatus.Location = new Point(28, 432);
        cboStatus.Name = "cboStatus";
        cboStatus.Size = new Size(200, 31);
        cboStatus.TabIndex = 10;
        // 
        // lblAssignField
        // 
        lblAssignField.AutoSize = true;
        lblAssignField.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblAssignField.ForeColor = Color.FromArgb(70, 70, 70);
        lblAssignField.Location = new Point(28, 476);
        lblAssignField.Name = "lblAssignField";
        lblAssignField.Size = new Size(151, 20);
        lblAssignField.TabIndex = 11;
        lblAssignField.Text = "Assign To (optional)";
        // 
        // cboAssigned
        // 
        cboAssigned.DropDownStyle = ComboBoxStyle.DropDownList;
        cboAssigned.Font = new Font("Segoe UI", 10F);
        cboAssigned.Location = new Point(28, 498);
        cboAssigned.Name = "cboAssigned";
        cboAssigned.Size = new Size(300, 31);
        cboAssigned.TabIndex = 12;
        // 
        // lblDeliveryField
        // 
        lblDeliveryField.AutoSize = true;
        lblDeliveryField.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblDeliveryField.ForeColor = Color.FromArgb(70, 70, 70);
        lblDeliveryField.Location = new Point(28, 542);
        lblDeliveryField.Name = "lblDeliveryField";
        lblDeliveryField.Size = new Size(130, 20);
        lblDeliveryField.TabIndex = 13;
        lblDeliveryField.Text = "Delivery Provider";
        // 
        // cboDelivery
        // 
        cboDelivery.DropDownStyle = ComboBoxStyle.DropDownList;
        cboDelivery.Font = new Font("Segoe UI", 10F);
        cboDelivery.Items.AddRange(new object[] { "— None —", "Uber", "DoorDash", "GrabHub", "Self Delivery" });
        cboDelivery.Location = new Point(28, 564);
        cboDelivery.Name = "cboDelivery";
        cboDelivery.Size = new Size(260, 31);
        cboDelivery.TabIndex = 14;
        // 
        // lblComplaintField
        // 
        lblComplaintField.AutoSize = true;
        lblComplaintField.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblComplaintField.ForeColor = Color.FromArgb(70, 70, 70);
        lblComplaintField.Location = new Point(28, 610);
        lblComplaintField.Name = "lblComplaintField";
        lblComplaintField.Size = new Size(118, 20);
        lblComplaintField.TabIndex = 15;
        lblComplaintField.Text = "Complaint Type";
        // 
        // cboComplaint
        // 
        cboComplaint.DropDownStyle = ComboBoxStyle.DropDownList;
        cboComplaint.Font = new Font("Segoe UI", 10F);
        cboComplaint.Items.AddRange(new object[] { "— None —", "Not Receive Food", "Food Bad Quality", "Missing Item", "Received Wrong Order" });
        cboComplaint.Location = new Point(28, 632);
        cboComplaint.Name = "cboComplaint";
        cboComplaint.Size = new Size(310, 31);
        cboComplaint.TabIndex = 16;
        // 
        // lblNotify
        // 
        lblNotify.Font = new Font("Segoe UI", 8.5F, FontStyle.Italic);
        lblNotify.ForeColor = Color.FromArgb(39, 120, 180);
        lblNotify.Location = new Point(28, 676);
        lblNotify.Name = "lblNotify";
        lblNotify.Size = new Size(524, 20);
        lblNotify.TabIndex = 17;
        lblNotify.Text = "ⓘ  After saving, the iOS app will receive the update within 10 seconds via polling.";
        // 
        // lblInfo
        // 
        lblInfo.Font = new Font("Segoe UI", 9F);
        lblInfo.Location = new Point(28, 704);
        lblInfo.Name = "lblInfo";
        lblInfo.Size = new Size(524, 22);
        lblInfo.TabIndex = 18;
        lblInfo.TextAlign = ContentAlignment.MiddleLeft;
        lblInfo.Visible = false;
        // 
        // btnSave
        // 
        btnSave.BackColor = Color.FromArgb(26, 58, 92);
        btnSave.Cursor = Cursors.Hand;
        btnSave.FlatAppearance.BorderSize = 0;
        btnSave.FlatStyle = FlatStyle.Flat;
        btnSave.Font = new Font("Segoe UI", 10F, FontStyle.Bold);
        btnSave.ForeColor = Color.White;
        btnSave.Location = new Point(28, 742);
        btnSave.Name = "btnSave";
        btnSave.Size = new Size(160, 38);
        btnSave.TabIndex = 19;
        btnSave.UseVisualStyleBackColor = false;
        btnSave.Click += btnSave_Click;
        // 
        // btnCancel
        // 
        btnCancel.Cursor = Cursors.Hand;
        btnCancel.FlatStyle = FlatStyle.Flat;
        btnCancel.Font = new Font("Segoe UI", 10F);
        btnCancel.Location = new Point(204, 742);
        btnCancel.Name = "btnCancel";
        btnCancel.Size = new Size(100, 38);
        btnCancel.TabIndex = 20;
        btnCancel.Text = "Cancel";
        btnCancel.Click += btnCancel_Click;
        // 
        // CaseDetailForm
        // 
        BackColor = Color.White;
        ClientSize = new Size(580, 806);
        Controls.Add(lblCaseInfo);
        Controls.Add(lblCreatedByField);
        Controls.Add(txtCreatedBy);
        Controls.Add(lblTitleField);
        Controls.Add(txtTitle);
        Controls.Add(lblDescField);
        Controls.Add(txtDescription);
        Controls.Add(lblSolutionField);
        Controls.Add(txtSolution);
        Controls.Add(lblStatusField);
        Controls.Add(cboStatus);
        Controls.Add(lblAssignField);
        Controls.Add(cboAssigned);
        Controls.Add(lblDeliveryField);
        Controls.Add(cboDelivery);
        Controls.Add(lblComplaintField);
        Controls.Add(cboComplaint);
        Controls.Add(lblNotify);
        Controls.Add(lblInfo);
        Controls.Add(btnSave);
        Controls.Add(btnCancel);
        Font = new Font("Segoe UI", 10.8F, FontStyle.Regular, GraphicsUnit.Point, 0);
        FormBorderStyle = FormBorderStyle.Fixed3D;
        Icon = (Icon)resources.GetObject("$this.Icon");
        MaximizeBox = false;
        Name = "CaseDetailForm";
        StartPosition = FormStartPosition.CenterParent;
        Text = "JPS Case Detail";
        ResumeLayout(false);
        PerformLayout();
    }

    // ── Control Declarations ─────────────────────────────────────────────────
    private Label    lblCaseInfo;
    private Label    lblCreatedByField;
    private TextBox  txtCreatedBy;
    private Label    lblTitleField;
    private TextBox  txtTitle;
    private Label    lblDescField;
    private TextBox  txtDescription;
    private Label    lblSolutionField;
    private TextBox  txtSolution;
    private Label    lblStatusField;
    private ComboBox cboStatus;
    private Label    lblAssignField;
    private ComboBox cboAssigned;
    private Label    lblDeliveryField;
    private ComboBox cboDelivery;
    private Label    lblComplaintField;
    private ComboBox cboComplaint;
    private Label    lblNotify;
    private Label    lblInfo;
    private Button   btnSave;
    private Button   btnCancel;
}
