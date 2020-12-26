class Matcher{
//Check the presence of unsual characters
static final validCharacters = RegExp(r'^[a-zA-Z0-9!@#%\$&*~= ]+$');
//Match if it contains a number an upper and lower case and a special character 
//and if the lenght is greater
static final validExpression = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#%\$&*~= ]).{15,}$');

static bool simpleMatcher(String value){
  return value.length > 4;
}
 static bool pass(String value){
        return validCharacters.hasMatch(value) && validExpression.hasMatch(value);
  }

  //Check if the username contains only letters and numbers
  static bool userName(String value){
      Pattern pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return false;
      else
        return true;

}
}