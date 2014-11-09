require "rspec/expectations"

module GooglePages
  class LoginPage < SitePrism::Page
    set_url "https://accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/"

    # deem.automation.qa
    # lp3$8)23%*@~[}x
    element :email, "#Email"
    element :password, "#Passwd"
    element :sign_in_button, "#signIn"
    element :re_auth, "#reauthEmail"

    def sign_in
      load
      if has_email?
        email.set("deem.automation.qa")
      elsif has_re_auth?
        raise "bad re-auth" unless re_auth.text == "deem.automation.qa@gmail.com"
      end
      password.set("lp3$8)23%*@~[}x")
      sign_in_button.click
    end
  end
end