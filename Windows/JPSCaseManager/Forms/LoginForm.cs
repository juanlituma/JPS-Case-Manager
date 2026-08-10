// Forms/LoginForm.cs — Login form logic and event handlers

using JPSCaseManager.Services;

namespace JPSCaseManager.Forms;

public partial class LoginForm : Form
{
    public LoginForm()
    {
        InitializeComponent();
    }

    // ── Event Handlers ───────────────────────────────────────────────────────

    private void btnLogin_Click(object sender, EventArgs e) => DoLogin();

    private void txtPassword_KeyDown(object sender, KeyEventArgs e)
    {
        if (e.KeyCode == Keys.Enter) DoLogin();
    }

    // ── Login Logic ──────────────────────────────────────────────────────────

    private async void DoLogin()
    {
        Config.BaseUrl = txtServer.Text.TrimEnd('/');

        if (string.IsNullOrWhiteSpace(txtUsername.Text) ||
            string.IsNullOrWhiteSpace(txtPassword.Text))
        {
            ShowError("Please enter username and password.");
            return;
        }

        btnLogin.Enabled = false;
        btnLogin.Text    = "Logging in…";
        lblError.Visible = false;

        try
        {
            await ApiService.LoginAsync(txtUsername.Text.Trim(), txtPassword.Text);

            var main = new MainForm();

            // When MainForm closes for any reason (X button OR logout), re-show this
            // LoginForm so the user can log in again.  Closing *this* LoginForm is the
            // only action that lets Application.Run() exit and ends the process.
            main.FormClosed += (_, _) =>
            {
                txtPassword.Clear();   // clear password for security on re-login
                Show();
            };

            main.Show();
            Hide();
        }
        catch (Exception ex)
        {
            ShowError(ex.Message);
            btnLogin.Enabled = true;
            btnLogin.Text    = "Login";
        }
    }

    private void ShowError(string msg)
    {
        lblError.Text    = msg;
        lblError.Visible = true;
    }
}
