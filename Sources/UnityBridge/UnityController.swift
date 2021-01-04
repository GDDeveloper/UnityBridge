import Foundation
import UnityFramework

public class UnityController: UIResponder, UIApplicationDelegate, UnityFrameworkListener {
	
	private var ufw : UnityFramework!
	private static var launchOptions : [UIApplication.LaunchOptionsKey: Any]?
	
	public func unityIsInitialized() -> Bool {
		return ufw != nil && (ufw.appController() != nil)
	}
	
	static func setLaunchOptions(_ launchOpts : [UIApplication.LaunchOptionsKey: Any]?){
		UnityController.launchOptions = launchOpts
	}
	
	@objc public func initUnity() {
		
		self.ufw = UnityFrameworkLoad()!
		ufw.setDataBundleId("com.unity3d.framework")
		ufw.register(self)
		ufw.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: UnityController.launchOptions)
	}
	
	public func getUnityWindowRootViewController() -> UIViewController? {
		return ufw.appController()?.window.rootViewController
	}
	
	public func getUnityRootViewController() -> UIViewController? {
		return ufw.appController()?.rootViewController
	}
	
	@objc public func unloadUnity() {
		if unityIsInitialized() {
			ufw.unloadApplication()
			ufw = nil
		}
	}
	
	private func UnityFrameworkLoad() -> UnityFramework? {
		let bundlePath: String = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
		
		let bundle = Bundle(path: bundlePath )
		if bundle?.isLoaded == false {
			bundle?.load()
		}
		
		let ufw = bundle?.principalClass?.getInstance()
		if ufw?.appController() == nil {
			// unity is not initialized
			//            ufw?.executeHeader = &mh_execute_header
			
			let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
			machineHeader.pointee = _mh_execute_header
			
			ufw!.setExecuteHeader(machineHeader)
		}
		return ufw
	}
}

