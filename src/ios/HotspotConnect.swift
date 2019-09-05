import Foundation
import NetworkExtension

@objc(HotspotConnect) class HotspotConnect : CDVPlugin {
    var CDVWebview:UIWebView;
    var command: CDVInvokedUrlCommand;
    var shouldCancel: Bool;

  // This is just called if <param name="onload" value="true" /> in plugin.xml.
    init(webView: UIWebView) {
        self.CDVWebview = webView
        self.command = CDVInvokedUrlCommand()
        self.shouldCancel = false
    }
    
    @objc(cancel:)
    func cancel(_ command: CDVInvokedUrlCommand) {
        self.shouldCancel = true
    }

    @objc(connect:)
    func connect(_ command: CDVInvokedUrlCommand) {
        self.command = command
        self.shouldCancel = false

        let ssid = command.arguments[0] as? String ?? ""
        let passphrase = command.arguments[1] as? String ?? ""
        let isPrefix = command.arguments[2] as? Bool ?? false

        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

        guard #available(iOS 11.0, *) else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Not supported")
                       self.commandDelegate.send(
                         pluginResult,
                         callbackId: self.command.callbackId
                       )
                       return
        }

        var hotspotConfig: NEHotspotConfiguration;

        if #available(iOS 13.0, *), isPrefix {
            if(passphrase.isEmpty) {
                hotspotConfig = NEHotspotConfiguration(ssidPrefix: ssid)
            } else {
                hotspotConfig = NEHotspotConfiguration(ssidPrefix: ssid, passphrase: passphrase, isWEP: false)
            }
        } else {
            if(passphrase.isEmpty) {
                hotspotConfig = NEHotspotConfiguration(ssid: ssid)
            } else {
                hotspotConfig = NEHotspotConfiguration(ssid: ssid, passphrase: passphrase, isWEP: false)
            }
        }

        NEHotspotConfigurationManager.shared.apply(hotspotConfig) {[unowned self] (error) in
            guard self.shouldCancel == false else {
                self.shouldCancel = false
                return
            }
            
            if let error = error {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
            }
            else {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            }

            self.commandDelegate.send(
              pluginResult,
              callbackId: self.command.callbackId
            )
        }
    }
}
