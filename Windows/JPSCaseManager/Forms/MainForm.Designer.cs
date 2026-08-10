// Forms/MainForm.Designer.cs

namespace JPSCaseManager.Forms;

partial class MainForm
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
        DataGridViewCellStyle dataGridViewCellStyle1 = new DataGridViewCellStyle();
        DataGridViewCellStyle dataGridViewCellStyle2 = new DataGridViewCellStyle();
        System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
        pnlHeader = new Panel();
        btnLogout = new Button();
        lblAppTitle = new Label();
        pnlToolbar = new Panel();
        lblStatus = new Label();
        cboStatus = new ComboBox();
        lblSearch = new Label();
        txtSearch = new TextBox();
        btnSearch = new Button();
        btnRefresh = new Button();
        grid = new DataGridView();
        pnlBottom = new Panel();
        btnEditCase = new Button();
        statusStrip = new StatusStrip();
        lblUser = new ToolStripStatusLabel();
        lblCount = new ToolStripStatusLabel();
        pnlHeader.SuspendLayout();
        pnlToolbar.SuspendLayout();
        ((System.ComponentModel.ISupportInitialize)grid).BeginInit();
        pnlBottom.SuspendLayout();
        statusStrip.SuspendLayout();
        SuspendLayout();
        // 
        // pnlHeader
        // 
        pnlHeader.BackColor = Color.FromArgb(26, 58, 92);
        pnlHeader.Controls.Add(btnLogout);
        pnlHeader.Controls.Add(lblAppTitle);
        pnlHeader.Dock = DockStyle.Top;
        pnlHeader.Location = new Point(0, 54);
        pnlHeader.Name = "pnlHeader";
        pnlHeader.Size = new Size(1100, 50);
        pnlHeader.TabIndex = 3;
        // 
        // btnLogout
        // 
        btnLogout.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        btnLogout.BackColor = Color.FromArgb(180, 50, 50);
        btnLogout.Cursor = Cursors.Hand;
        btnLogout.FlatAppearance.BorderSize = 0;
        btnLogout.FlatStyle = FlatStyle.Flat;
        btnLogout.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        btnLogout.ForeColor = Color.White;
        btnLogout.Location = new Point(903, 10);
        btnLogout.Name = "btnLogout";
        btnLogout.Size = new Size(85, 30);
        btnLogout.TabIndex = 0;
        btnLogout.Text = "Logout";
        btnLogout.UseVisualStyleBackColor = false;
        btnLogout.Click += btnLogout_Click;
        // 
        // lblAppTitle
        // 
        lblAppTitle.Dock = DockStyle.Fill;
        lblAppTitle.Font = new Font("Segoe UI", 14F, FontStyle.Bold);
        lblAppTitle.ForeColor = Color.White;
        lblAppTitle.Location = new Point(0, 0);
        lblAppTitle.Name = "lblAppTitle";
        lblAppTitle.Padding = new Padding(16, 0, 0, 0);
        lblAppTitle.Size = new Size(1100, 50);
        lblAppTitle.TabIndex = 1;
        lblAppTitle.Text = "JPS  Case Management";
        lblAppTitle.TextAlign = ContentAlignment.MiddleLeft;
        // 
        // pnlToolbar
        // 
        pnlToolbar.BackColor = Color.FromArgb(245, 246, 248);
        pnlToolbar.Controls.Add(lblStatus);
        pnlToolbar.Controls.Add(cboStatus);
        pnlToolbar.Controls.Add(lblSearch);
        pnlToolbar.Controls.Add(txtSearch);
        pnlToolbar.Controls.Add(btnSearch);
        pnlToolbar.Controls.Add(btnRefresh);
        pnlToolbar.Dock = DockStyle.Top;
        pnlToolbar.Location = new Point(0, 0);
        pnlToolbar.Name = "pnlToolbar";
        pnlToolbar.Size = new Size(1100, 54);
        pnlToolbar.TabIndex = 4;
        // 
        // lblStatus
        // 
        lblStatus.AutoSize = true;
        lblStatus.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblStatus.Location = new Point(12, 18);
        lblStatus.Name = "lblStatus";
        lblStatus.Size = new Size(57, 20);
        lblStatus.TabIndex = 0;
        lblStatus.Text = "Status:";
        // 
        // cboStatus
        // 
        cboStatus.DropDownStyle = ComboBoxStyle.DropDownList;
        cboStatus.Font = new Font("Segoe UI", 9F);
        cboStatus.Items.AddRange(new object[] { "All", "Open", "In Progress", "Resolved" });
        cboStatus.Location = new Point(67, 14);
        cboStatus.Name = "cboStatus";
        cboStatus.Size = new Size(130, 28);
        cboStatus.TabIndex = 1;
        cboStatus.SelectedIndexChanged += cboStatus_SelectedIndexChanged;
        // 
        // lblSearch
        // 
        lblSearch.AutoSize = true;
        lblSearch.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblSearch.Location = new Point(215, 18);
        lblSearch.Name = "lblSearch";
        lblSearch.Size = new Size(59, 20);
        lblSearch.TabIndex = 2;
        lblSearch.Text = "Search:";
        // 
        // txtSearch
        // 
        txtSearch.Font = new Font("Segoe UI", 9F);
        txtSearch.Location = new Point(273, 14);
        txtSearch.Name = "txtSearch";
        txtSearch.Size = new Size(220, 27);
        txtSearch.TabIndex = 3;
        txtSearch.KeyDown += txtSearch_KeyDown;
        // 
        // btnSearch
        // 
        btnSearch.BackColor = Color.FromArgb(26, 58, 92);
        btnSearch.Cursor = Cursors.Hand;
        btnSearch.FlatAppearance.BorderSize = 0;
        btnSearch.FlatStyle = FlatStyle.Flat;
        btnSearch.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        btnSearch.ForeColor = Color.White;
        btnSearch.Location = new Point(511, 12);
        btnSearch.Name = "btnSearch";
        btnSearch.Size = new Size(80, 30);
        btnSearch.TabIndex = 4;
        btnSearch.Text = "Search";
        btnSearch.UseVisualStyleBackColor = false;
        btnSearch.Click += btnSearch_Click;
        // 
        // btnRefresh
        // 
        btnRefresh.Cursor = Cursors.Hand;
        btnRefresh.FlatStyle = FlatStyle.Flat;
        btnRefresh.Font = new Font("Segoe UI", 9F);
        btnRefresh.Location = new Point(607, 12);
        btnRefresh.Name = "btnRefresh";
        btnRefresh.Size = new Size(90, 30);
        btnRefresh.TabIndex = 5;
        btnRefresh.Text = "↻  Refresh";
        btnRefresh.Click += btnRefresh_Click;
        // 
        // grid
        // 
        grid.AllowUserToAddRows = false;
        grid.AllowUserToDeleteRows = false;
        dataGridViewCellStyle1.BackColor = Color.FromArgb(249, 250, 252);
        grid.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
        grid.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        grid.BackgroundColor = Color.White;
        grid.BorderStyle = BorderStyle.None;
        dataGridViewCellStyle2.Alignment = DataGridViewContentAlignment.MiddleLeft;
        dataGridViewCellStyle2.BackColor = Color.FromArgb(240, 242, 245);
        dataGridViewCellStyle2.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        dataGridViewCellStyle2.ForeColor = Color.FromArgb(50, 50, 50);
        dataGridViewCellStyle2.SelectionBackColor = SystemColors.Highlight;
        dataGridViewCellStyle2.SelectionForeColor = SystemColors.HighlightText;
        dataGridViewCellStyle2.WrapMode = DataGridViewTriState.True;
        grid.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
        grid.ColumnHeadersHeight = 36;
        grid.Dock = DockStyle.Fill;
        grid.EnableHeadersVisualStyles = false;
        grid.Font = new Font("Segoe UI", 9F);
        grid.GridColor = Color.FromArgb(230, 230, 230);
        grid.Location = new Point(0, 104);
        grid.MultiSelect = false;
        grid.Name = "grid";
        grid.ReadOnly = true;
        grid.RowHeadersVisible = false;
        grid.RowHeadersWidth = 51;
        grid.RowTemplate.Height = 34;
        grid.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
        grid.Size = new Size(1100, 520);
        grid.TabIndex = 0;
        grid.CellDoubleClick += grid_CellDoubleClick;
        // 
        // pnlBottom
        // 
        pnlBottom.BackColor = Color.FromArgb(245, 246, 248);
        pnlBottom.Controls.Add(btnEditCase);
        pnlBottom.Dock = DockStyle.Bottom;
        pnlBottom.Location = new Point(0, 650);
        pnlBottom.Name = "pnlBottom";
        pnlBottom.Size = new Size(1100, 50);
        pnlBottom.TabIndex = 2;
        // 
        // btnEditCase
        // 
        btnEditCase.BackColor = Color.FromArgb(26, 58, 92);
        btnEditCase.Cursor = Cursors.Hand;
        btnEditCase.FlatAppearance.BorderSize = 0;
        btnEditCase.FlatStyle = FlatStyle.Flat;
        btnEditCase.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        btnEditCase.ForeColor = Color.White;
        btnEditCase.Location = new Point(10, 10);
        btnEditCase.Name = "btnEditCase";
        btnEditCase.Size = new Size(170, 30);
        btnEditCase.TabIndex = 0;
        btnEditCase.Text = "✏  Edit Selected Case";
        btnEditCase.UseVisualStyleBackColor = false;
        btnEditCase.Click += btnEditCase_Click;
        // 
        // statusStrip
        // 
        statusStrip.BackColor = Color.FromArgb(235, 237, 240);
        statusStrip.ImageScalingSize = new Size(20, 20);
        statusStrip.Items.AddRange(new ToolStripItem[] { lblUser, lblCount });
        statusStrip.Location = new Point(0, 624);
        statusStrip.Name = "statusStrip";
        statusStrip.Size = new Size(1100, 26);
        statusStrip.TabIndex = 1;
        // 
        // lblUser
        // 
        lblUser.Name = "lblUser";
        lblUser.Size = new Size(82, 20);
        lblUser.Text = "  Loading…";
        // 
        // lblCount
        // 
        lblCount.Name = "lblCount";
        lblCount.Size = new Size(1003, 20);
        lblCount.Spring = true;
        lblCount.TextAlign = ContentAlignment.MiddleRight;
        // 
        // MainForm
        // 
        BackColor = Color.White;
        ClientSize = new Size(1100, 700);
        Controls.Add(grid);
        Controls.Add(statusStrip);
        Controls.Add(pnlBottom);
        Controls.Add(pnlHeader);
        Controls.Add(pnlToolbar);
        Icon = (Icon)resources.GetObject("$this.Icon");
        MinimumSize = new Size(900, 550);
        Name = "MainForm";
        StartPosition = FormStartPosition.CenterScreen;
        Text = "JPS Case Management";
        pnlHeader.ResumeLayout(false);
        pnlToolbar.ResumeLayout(false);
        pnlToolbar.PerformLayout();
        ((System.ComponentModel.ISupportInitialize)grid).EndInit();
        pnlBottom.ResumeLayout(false);
        statusStrip.ResumeLayout(false);
        statusStrip.PerformLayout();
        ResumeLayout(false);
        PerformLayout();
    }

    // ── Control Declarations ─────────────────────────────────────────────────
    private Panel                  pnlHeader;
    private Label                  lblAppTitle;
    private Button                 btnLogout;
    private Panel                  pnlToolbar;
    private Label                  lblStatus;
    private ComboBox               cboStatus;
    private Label                  lblSearch;
    private TextBox                txtSearch;
    private Button                 btnSearch;
    private Button                 btnRefresh;
    private DataGridView           grid;
    private Panel                  pnlBottom;
    private Button                 btnEditCase;
    private StatusStrip            statusStrip;
    private ToolStripStatusLabel   lblUser;
    private ToolStripStatusLabel   lblCount;
}
