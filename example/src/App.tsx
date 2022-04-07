
 import React from 'react';
 import {
   SafeAreaView,
   ScrollView,
   StatusBar,
   Text,
   useColorScheme,
   View,
 } from 'react-native';
 
 import {
   Colors,
   Header,
 } from 'react-native/Libraries/NewAppScreen';
 
 const App: () => any = () => {
   const isDarkMode = useColorScheme() === 'dark';
 
   const backgroundStyle = {
     backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
   };
 
   return (
     <SafeAreaView style={backgroundStyle}>
       <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
       <ScrollView
         contentInsetAdjustmentBehavior="automatic"
         style={backgroundStyle}>
         <Header />
         <View
           style={{
             backgroundColor: isDarkMode ? Colors.black : Colors.white,
           }}>
             <Text style={{ padding: 20 }}>{"Hello, this is Andrew Brown from ExamPro"}</Text>
         </View>
       </ScrollView>
     </SafeAreaView>
   );
 };
 
 export default App;