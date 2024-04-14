import 'package:flutter/material.dart';
import 'package:flutter_application_3/Components/color.dart';
import 'package:flutter_application_3/Onboarding/onboarding_items.dart';
import 'package:flutter_application_3/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key}); 

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = OnboardingItems();
  final pageController = PageController();

  bool isLastPage = false;

  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        color: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child: isLastPage? getStarted() : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                //Skip Button
                TextButton(
                    onPressed: ()=>pageController.jumpToPage(controller.items.length-1),
                    child: const Text("Skip")),

                //Indicator
                SmoothPageIndicator(
                    controller: pageController,
                    count: controller.items.length,
                    onDotClicked: (index)=> pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 600), curve: Curves.easeIn),
                    effect: const WormEffect(
                      dotHeight: 12,
                      dotWidth: 12,
                      activeDotColor: Colors.black,
                    ),
                ),

                //Next Button
                TextButton(
                    onPressed: ()=>pageController.nextPage(
                        duration: const Duration(milliseconds: 600), curve: Curves.easeIn),
                    child: const Text("Next")),

              ],
            ),
          ),
          body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Stack(
            children: [
            
            PageView.builder(
                onPageChanged: (index)=> setState(()=> isLastPage = controller.items.length-1 == index),
                itemCount: controller.items.length,
                controller: pageController,
                itemBuilder: (context,index){
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(controller.items[index].image),
                      const SizedBox(height: 15),
                      Text(controller.items[index].title,
                        style: const TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                      const SizedBox(height: 15),
                      Text(controller.items[index].descriptions,
                          style: const TextStyle(color: Color.fromARGB(255, 63, 63, 63),fontSize: 17), textAlign: TextAlign.center),
                    ],
                  );

                }),
            ],
            ),
        ),
    );
  }

  //Now the problem is when press get started button
  // after re run the app we see again the onboarding screen
  // so lets do one time onboarding

  //Get started button

 Widget getStarted(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black
      ),
      width: MediaQuery.of(context).size.width * .9,
      height: 55,
      child: TextButton(
          onPressed: ()async{
            final pres = await SharedPreferences.getInstance();
            pres.setBool("onboarding", false);

            //After we press get started button this onboarding value become true
            // same key
            if(!mounted)return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
          },
          child: const Text("Get started",style: TextStyle(color: Colors.white),)),
    );
 }
}