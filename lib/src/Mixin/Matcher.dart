class Matcher{
/*Check if value only contains alphanumeric 
and this special characters!@#%\$&*~=() */
 static bool pass(String value){
        return new RegExp(r'^[a-zA-Z0-9!@#%\$&*~=() ]+$').hasMatch(value);
  }

  //Check if the userName contains only letters and numbers
  static bool userName(String username){    
    return new RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username);
}
}