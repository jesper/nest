import QtQuick 1.1

Rectangle {
    id: main
    width: 400
    height: 700

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#83A7C4" }
        GradientStop { position: 1.0; color: "#00509C" }
    }

    signal signal_login(string email, string password);
    signal signal_postMessage(string message);
    signal signal_getLatestPosts();
    signal signal_groupClicked(int groupIndex)

    function slot_positionStreamTop()
    {
        stream.streamList.positionViewAtBeginning();
    }

    function slot_loginFailed(reason)
    {
        loginWindow.loginButton.text = "Login"
        loginWindow.errrorMessage = reason;

        setLoginDisabled(false)
    }

    function slot_loginStatusAuthenticating()
    {
        loginWindow.loginButton.text = "Authenticating..."
    }

    function slot_loginStatusLoadingStream()
    {
        loginWindow.loginButton.text = "Getting Messages..."
    }

    // Would rather make this an affermitive "setLoginEnabled", but not sure how to expose it as a property in that way
    // (other than renaming this function and doing "!disabled")
    function setLoginDisabled(disabled)
    {
        loginWindow.loginButton.disabled = disabled
        loginWindow.email.disabled = disabled
        loginWindow.password.disabled = disabled
    }

    function login(email, password)
    {
        setLoginDisabled(true)
        loginWindow.errrorMessage = ""

        loginWindow.loginButton.text = "Connecting..."

        signal_login(email, password);
    }

    function postMessage(message)
    {
        stream.messageInput.disabled = true;
        signal_postMessage(message);
    }

    function groupLoadedSuccess()
    {
        stream.messageInput.disabled = false;
        stream.messageInput.input.text = "";
        stream.loadingHeaderText = "Done"
        stream.showLoadingHeader = false;
    }

    function loginSuccess()
    {
        stream.x = main.width;
        stream.visible = true;
        stream.animate = true;

        loginWindow.x = loginWindow.width * -1

        stream.x = 0
    }

    Login {
        id: loginWindow
        width: parent.width
        height: parent.height
    }

    Stream {
        id: stream
        visible: false
        width: parent.width
        height: parent.height
    }
}
