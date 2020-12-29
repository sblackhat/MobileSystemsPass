class Matcher{
//Check the presence of unsual characters
static final validCharacters = RegExp(r'^[a-zA-Z0-9!@#%\$&*~=() ]+$');
//Check if the password is more than 20 characters long
static bool simpleMatcher(String value){
  return value.length > 20;
}
 static bool pass(String value){
        return validCharacters.hasMatch(value);
  }

  //Check if the email contains only letters and numbers
  static bool email(String value){
      Pattern pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return false;
      else
        return true;

}
}