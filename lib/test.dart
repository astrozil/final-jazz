import 'package:dartz/dartz.dart';

void main(){

  bool num = true;
  Either<String,int> test(){
    if(num == true){
      return right(1);
    }else{
      return left("");
    }
  }
  Either<String,int> test2(){
    return test();
  }
   var test3 = test2();
  test3.fold(
      (s){
        print("left");
      },
      (r){
        print("right");
      }
  );
}