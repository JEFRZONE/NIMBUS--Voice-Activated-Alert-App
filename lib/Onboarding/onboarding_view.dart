import 'package:flutter/material.dart';
import 'package:flutter_application_3/Onboarding/onboarding_items.dart';
import 'package:flutter_application_3/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_application_3/login.dart';

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
      backgroundColor: Colors.white,
      bottomSheet: Container(
        color: Colors.white,
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
                        duration: const Duration(milliseconds: 50), curve: Curves.easeIn),
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
        Stack(
          children: [
            Container(
              height: 600, // adjust the height to your liking
              width: double.infinity,
              child: Image.asset(controller.items[index].image),
            ),
            Positioned(
              top: 1, // adjust the top value to your liking
              left: 165, // adjust the left value to your liking
              child: Container(
                height: 100, // adjust the height to your liking
                width: 100, // adjust the width to your liking
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/nimbus1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(controller.items[index].title,
          style: const TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
        const SizedBox(height: 15),
        Text(controller.items[index].descriptions,
          style: const TextStyle(color: Colors.black,fontSize: 17), textAlign: TextAlign.center),
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
          },
          child: const Text("Get started",style: TextStyle(color: Colors.white),)),
    );
 }
}