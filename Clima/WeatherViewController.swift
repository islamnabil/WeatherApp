//  Created by Islam on 10/08/2018.
//  Copyright (c) 2018 Islam ElGaafary. All rights reserved.
//


import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController , CLLocationManagerDelegate , changeCityNameDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "7128bf67ef7252cbb73773843f9347e7"//"e72ca729af228beabd5d20e3b7749713"
    

    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    
    func getWeatherData (url: String , params : [String:String]){
      
        Alamofire.request(url , parameters : params).responseJSON { response in
            
            
            if response.result.isSuccess {
                print("Success to get Weather data")
                let weathrJSON : JSON = JSON(response.result.value)
                self.UpdateWeatherData(json : weathrJSON)
                print(weathrJSON)
            }else {
                print("Error: \(response.result.error)")
                self.cityLabel.text = "Connection Issue!"
            }
         
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    func UpdateWeatherData (json : JSON){
       
        if let tempResult = json["main"]["temp"].double {
        weatherDataModel.temprature = Int (tempResult - 273.15 )
        weatherDataModel.city = json["name"].stringValue ;
        weatherDataModel.Condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.Condition)
        
        updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    func updateUIWithWeatherData (){
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temprature)°"
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
           // locationManager.delegate = nil
            print (" longitude = \( location.coordinate.longitude),  Latitude = \( location.coordinate.latitude)");
            
            let longitude = String (location.coordinate.longitude)
            let Latitude = String (location.coordinate.latitude)
            
            let params : [String : String] = ["lat" : Latitude , "lon" : longitude , "appid": APP_ID] ;

            getWeatherData(url : WEATHER_URL , params: params) ;
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error) ;
        cityLabel.text = "Location Unavailable" ;
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    func userChangeCityName(city: String) {
        
        let params : [String : String] = ["q" : city , "appid": APP_ID] ;
        
        getWeatherData(url : WEATHER_URL , params: params) ;
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


