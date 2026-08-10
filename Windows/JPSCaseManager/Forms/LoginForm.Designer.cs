// Forms/LoginForm.Designer.cs — Auto-generated designer code

namespace JPSCaseManager.Forms;

partial class LoginForm
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
        System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(LoginForm));
        pnlHeader = new Panel();
        Logo = new PictureBox();
        lblTitle = new Label();
        lblSubtitle = new Label();
        pnlForm = new Panel();
        lblServer = new Label();
        txtServer = new TextBox();
        lblUsername = new Label();
        txtUsername = new TextBox();
        lblPassword = new Label();
        txtPassword = new TextBox();
        btnLogin = new Button();
        lblError = new Label();
        pnlHeader.SuspendLayout();
        ((System.ComponentModel.ISupportInitialize)Logo).BeginInit();
        pnlForm.SuspendLayout();
        SuspendLayout();
        // 
        // pnlHeader
        // 
        pnlHeader.BackColor = Color.FromArgb(26, 58, 92);
        pnlHeader.Controls.Add(Logo);
        pnlHeader.Controls.Add(lblTitle);
        pnlHeader.Dock = DockStyle.Top;
        pnlHeader.Location = new Point(0, 0);
        pnlHeader.Name = "pnlHeader";
        pnlHeader.Size = new Size(514, 213);
        pnlHeader.TabIndex = 0;
        // 
        // Logo
        // 
        Logo.BackColor = Color.LightGray;
        Logo.Image = (Image)resources.GetObject("Logo.Image");
        Logo.Location = new Point(189, 27);
        Logo.Name = "Logo";
        Logo.Size = new Size(133, 130);
        Logo.SizeMode = PictureBoxSizeMode.StretchImage;
        Logo.TabIndex = 2;
        Logo.TabStop = false;
        // 
        // lblTitle
        // 
        lblTitle.Font = new Font("Segoe UI", 13F, FontStyle.Bold);
        lblTitle.ForeColor = Color.White;
        lblTitle.Location = new Point(65, 166);
        lblTitle.Name = "lblTitle";
        lblTitle.Size = new Size(380, 28);
        lblTitle.TabIndex = 1;
        lblTitle.Text = "Case Management";
        lblTitle.TextAlign = ContentAlignment.MiddleCenter;
        // 
        // lblSubtitle
        // 
        lblSubtitle.Location = new Point(0, 0);
        lblSubtitle.Name = "lblSubtitle";
        lblSubtitle.Size = new Size(100, 23);
        lblSubtitle.TabIndex = 0;
        // 
        // pnlForm
        // 
        pnlForm.BackColor = Color.White;
        pnlForm.Controls.Add(lblServer);
        pnlForm.Controls.Add(txtServer);
        pnlForm.Controls.Add(lblUsername);
        pnlForm.Controls.Add(txtUsername);
        pnlForm.Controls.Add(lblPassword);
        pnlForm.Controls.Add(txtPassword);
        pnlForm.Controls.Add(btnLogin);
        pnlForm.Controls.Add(lblError);
        pnlForm.Location = new Point(0, 234);
        pnlForm.Name = "pnlForm";
        pnlForm.Size = new Size(513, 356);
        pnlForm.TabIndex = 1;
        // 
        // lblServer
        // 
        lblServer.AutoSize = true;
        lblServer.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblServer.ForeColor = Color.FromArgb(80, 80, 80);
        lblServer.Location = new Point(65, 20);
        lblServer.Name = "lblServer";
        lblServer.Size = new Size(87, 20);
        lblServer.TabIndex = 0;
        lblServer.Text = "Server URL";
        // 
        // txtServer
        // 
        txtServer.BackColor = Color.FromArgb(245, 246, 248);
        txtServer.BorderStyle = BorderStyle.FixedSingle;
        txtServer.Font = new Font("Segoe UI", 10F);
        txtServer.Location = new Point(65, 43);
        txtServer.Name = "txtServer";
        txtServer.Size = new Size(392, 30);
        txtServer.TabIndex = 1;
        txtServer.Text = "http://192.168.66.4:8282";
        // 
        // lblUsername
        // 
        lblUsername.AutoSize = true;
        lblUsername.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblUsername.ForeColor = Color.FromArgb(80, 80, 80);
        lblUsername.Location = new Point(65, 86);
        lblUsername.Name = "lblUsername";
        lblUsername.Size = new Size(80, 20);
        lblUsername.TabIndex = 2;
        lblUsername.Text = "Username";
        // 
        // txtUsername
        // 
        txtUsername.BackColor = Color.FromArgb(245, 246, 248);
        txtUsername.BorderStyle = BorderStyle.FixedSingle;
        txtUsername.Font = new Font("Segoe UI", 10F);
        txtUsername.Location = new Point(65, 109);
        txtUsername.Name = "txtUsername";
        txtUsername.Size = new Size(392, 30);
        txtUsername.TabIndex = 3;
        // 
        // lblPassword
        // 
        lblPassword.AutoSize = true;
        lblPassword.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        lblPassword.ForeColor = Color.FromArgb(80, 80, 80);
        lblPassword.Location = new Point(65, 151);
        lblPassword.Name = "lblPassword";
        lblPassword.Size = new Size(76, 20);
        lblPassword.TabIndex = 4;
        lblPassword.Text = "Password";
        // 
        // txtPassword
        // 
        txtPassword.BackColor = Color.FromArgb(245, 246, 248);
        txtPassword.BorderStyle = BorderStyle.FixedSingle;
        txtPassword.Font = new Font("Segoe UI", 10F);
        txtPassword.Location = new Point(65, 174);
        txtPassword.Name = "txtPassword";
        txtPassword.Size = new Size(392, 30);
        txtPassword.TabIndex = 5;
        txtPassword.UseSystemPasswordChar = true;
        txtPassword.KeyDown += txtPassword_KeyDown;
        // 
        // btnLogin
        // 
        btnLogin.BackColor = Color.FromArgb(26, 58, 92);
        btnLogin.Cursor = Cursors.Hand;
        btnLogin.FlatAppearance.BorderSize = 0;
        btnLogin.FlatStyle = FlatStyle.Flat;
        btnLogin.Font = new Font("Segoe UI", 11F, FontStyle.Bold);
        btnLogin.ForeColor = Color.White;
        btnLogin.Location = new Point(87, 231);
        btnLogin.Name = "btnLogin";
        btnLogin.Size = new Size(348, 42);
        btnLogin.TabIndex = 6;
        btnLogin.Text = "Login";
        btnLogin.UseVisualStyleBackColor = false;
        btnLogin.Click += btnLogin_Click;
        // 
        // lblError
        // 
        lblError.Font = new Font("Segoe UI", 9F);
        lblError.ForeColor = Color.Crimson;
        lblError.Location = new Point(36, 276);
        lblError.Name = "lblError";
        lblError.Size = new Size(348, 40);
        lblError.TabIndex = 7;
        lblError.TextAlign = ContentAlignment.MiddleCenter;
        lblError.Visible = false;
        // 
        // LoginForm
        // 
        BackColor = Color.White;
        ClientSize = new Size(514, 593);
        Controls.Add(pnlHeader);
        Controls.Add(pnlForm);
        FormBorderStyle = FormBorderStyle.FixedSingle;
        Icon = (Icon)resources.GetObject("$this.Icon");
        MaximizeBox = false;
        Name = "LoginForm";
        StartPosition = FormStartPosition.CenterScreen;
        Text = "JPS Case Management — Login";
        pnlHeader.ResumeLayout(false);
        ((System.ComponentModel.ISupportInitialize)Logo).EndInit();
        pnlForm.ResumeLayout(false);
        pnlForm.PerformLayout();
        ResumeLayout(false);
    }

    // ── Control Declarations ─────────────────────────────────────────────────
    private Panel   pnlHeader;
    private Label   lblTitle;
    private Label   lblSubtitle;
    private Panel   pnlForm;
    private Label   lblServer;
    private TextBox txtServer;
    private Label   lblUsername;
    private TextBox txtUsername;
    private Label   lblPassword;
    private TextBox txtPassword;
    private Button  btnLogin;
    private Label   lblError;
    private PictureBox Logo;
}
