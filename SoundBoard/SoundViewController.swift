//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by John Samuel Altamirano Sanchez on 10/20/21.
//  Copyright © 2021 empresa. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    
    @IBOutlet weak var lblTime: UILabel!
    
    
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    
    var timer = Timer()
    var minutos = 0 // variable minuto
    var segundos = 0 //varible integer
    
    @objc func cadaSegundo(){
        segundos += 1
        
        if(segundos > 59){
            segundos = 0
            minutos += 1
        }
        
        lblTime.text = "\(minutos) : \(segundos)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()

        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        // Do any additional setup after loading the view.
        
        
    }
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            //deterner la grabacion
            timer.invalidate() //detenemos el contador
            
            
            grabarAudio?.stop()
            //Cambiar texo del boton grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            
        }else{
            segundos = 0
            //Empesar a grabar
            grabarAudio?.record()
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(cadaSegundo), userInfo: nil, repeats: true)
            
            //CAmbiar el texto de boton grabar a detener
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
        }
    }
    
    @IBAction func reproducirTapped(_ sender: UIButton) {
    
        
        do{
          
        try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            
                reproducirAudio!.play()
                print("Reprodiciendo")
                reproducirButton.setTitle("REPRODUCIR ", for: .normal )
                
            
            
        }catch{}
    }
        
    @IBAction func agregarTapped(_ sender: Any) {
        let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.tiempo = lblTime.text
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
        
    }
    
    func configurarGrabacion(){
        do{
            // Creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //Creando la direccion para el archivo audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            //Impresion de rutas donde se guardan los archivos
            print("**************************")
            print(audioURL!)
            print("**************************")
            
            //Crear opciones para el grabador de audio
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de grabaciones de auido
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            
        }catch let error as NSError{
            print(error)
        }
        
    }
    
    
}
