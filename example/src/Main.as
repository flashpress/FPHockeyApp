package
{
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.ByteArray;

    import ru.flashpress.hockeyapp.FPHockeyApp;
    import ru.flashpress.hockeyapp.constants.FPAuthenticatorIdentificationType;
    import ru.flashpress.hockeyapp.constants.FPCrashManagerStatus;
    import ru.flashpress.hockeyapp.constants.FPCrashManagerUserInput;
    import ru.flashpress.hockeyapp.constants.NSStringEncoding;
    import ru.flashpress.hockeyapp.data.FPCrashMetaData;
    import ru.flashpress.hockeyapp.data.FPhaAttachmentBytes;
    import ru.flashpress.hockeyapp.data.FPhaAttachmentFile;
    import ru.flashpress.hockeyapp.data.FPhaUserData;
    import ru.flashpress.hockeyapp.events.FPhaEvent;
    import ru.flashpress.hockeyapp.ns.haIOS;

    import ui.PNGEncoder;

    import ui.Panel;
    import ui.PanelEvent;

    public class Main extends Sprite
    {
        private static const info:XML = <info>
            <soc id="Base" >
                <button id="configureWithIdentifier" />
                <button id="startManager" />
                <button id="start beta" />
                <button id="use live id" />
                <button id="start anonymous" />
                <button id="start ha user" />
                <button id="start device" />
                <button id="handleUserInput" />
                <button id="serverUrl" />
                <button id="disableCrashManager" />
                <button id="disableFeedbackManager" />
                <button id="appEnvironment" />
                <button id="installString" />
                <button id="debugLogEnabled" />
                <button id="testIdentifier" />
                <button id="default user" />
                <button id="userID" />
                <button id="userName" />
                <button id="userEmail" />
                <button id="test" />
                <button id="test_crash" />
            </soc>
            <soc id="Authenticator">
                <button id="authenticateInstallation" />
                <button id="restrictApplicationUsage" />
                <button id="restrictionEnforcementFrequency" />
                <button id="webpageURL" />
                <button id="deviceAuthenticationURL" />
                <button id="urlScheme" />
                <button id="identifyWithCompletion" />
                <button id="identified" />
                <button id="validateWithCompletion" />
                <button id="validated" />
                <button id="cleanupInternalStorage" />
                <button id="publicInstallationIdentifier" />
            </soc>
            <soc id="Feedback">
                <button id="sample" />
                <button id="with items" />
                <button id="with screenshot" />
                <button id="feedback list" />
                <button id="showFirstRequiredPresentationModal" />
                <button id="hideImageAttachmentButton" />
            </soc>
            <soc id="Crash">
                <button id="generateTestCrash" />
                <button id="showAlwaysButton" />
                <button id="status DISABLED" />
                <button id="status ALWAYS_ASK" />
                <button id="status AUTO_SEND" />
                <button id="setAlertViewHandler" />
                <button id="showAlertView" />
            </soc>
        </info>;
        //
        private static const BETA_ID:String = '700921090cb14215ac89722626cf29bd';
        private static const LIVE_ID:String = '700921090cb14215ac89722626cf29bd';
        //
        private var log:TextField;
        use namespace haIOS;
        public function Main()
        {
            super();
            //
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            //
            createUI();
            //
            addLog('new FPHockeyApp');
            addLog(' aneVersion: '+FPHockeyApp.VERSION+'.'+FPHockeyApp.BUILD);
            addLog(' isSupported'+FPHockeyApp.manager.isSupported);
            if (!FPHockeyApp.manager.isSupported) {
                return;
            }
            initHockeyApp();
        }

        private function createUI():void
        {
            log = new TextField();
            log.defaultTextFormat = new TextFormat('Tahoma', 22);
            log.border = true;
            log.background = true;
            log.autoSize = TextFieldAutoSize.NONE;
            log.x = 20;
            log.y = 50;
            log.width = stage.fullScreenWidth-log.x*2;
            log.height = 200;
            this.addChild(log);
            log.multiline = true;
            log.wordWrap = true;
            //
            var panel:Panel = new Panel(info);
            panel.x = log.x;
            panel.y = log.height+50;
            panel.width = stage.fullScreenWidth;
            panel.height = stage.fullScreenHeight-(panel.y+panel.height);
            panel.buttonWidth = 300;
            panel.buttonHeight = 60;
            panel.addEventListener(PanelEvent.ACTION, socViewAction);
            this.addChild(panel);
        }

        private function initHockeyApp():void
        {
            FPHockeyApp.manager.init();
            addLog(' sdkVersion: '+FPHockeyApp.VERSION_HA_SDK+' / '+FPHockeyApp.VERSION_HA_BUILD);
            addLog(' osVersion: '+FPHockeyApp.systemVersion);
            //
            FPHockeyApp.manager.feedback.addEventListener(FPhaEvent.FEEDBACK_SEND_FINISH, feedbackCompleteHandler);
            FPHockeyApp.manager.crash.addEventListener(FPhaEvent.CRASH_ALERT_SHOW, crashEventHandler);
            FPHockeyApp.manager.crash.addEventListener(FPhaEvent.CRASH_ALERT_DISMISS, crashEventHandler);
            FPHockeyApp.manager.crash.addEventListener(FPhaEvent.CRASH_GET_LOG, crashEventHandler);
            FPHockeyApp.manager.crash.addEventListener(FPhaEvent.CRASH_GET_ATTACHMENT, crashEventHandler);
            FPHockeyApp.manager.crash.addEventListener(FPhaEvent.CRASH_SEND_WILL, crashEventHandler);
            FPHockeyApp.manager.crash.addEventListener(FPhaEvent.CRASH_SEND_FAIL, crashEventHandler);
            FPHockeyApp.manager.crash.addEventListener(FPhaEvent.CRASH_SEND_FINISH, crashEventHandler);
            //
            FPHockeyApp.usernameEncodingGet = NSStringEncoding.NSUTF8StringEncoding;
        }

        private function feedbackCompleteHandler(event:FPhaEvent):void
        {
            addLog('feedbackComplete:'+event.composeResult);
        }
        private function crashEventHandler(event:FPhaEvent):void
        {
            addLog('crashEvent:'+event.type);
            switch (event.type) {
                case FPhaEvent.CRASH_ALERT_SHOW:
                    crashAction('showAlertView');
                    break;
                case FPhaEvent.CRASH_ALERT_DISMISS:
                    addLog('	buttonIndex:'+event.buttonIndex);
                    addLog('	userDescription:'+event.userDescription);
                    crashAlertDismiss(event.buttonIndex, event.userDescription);
                    break;
                case FPhaEvent.CRASH_SEND_FAIL:
                    addLog('	error:');
                    addLog(event.errorData.toString());
                    break;
            }
        }
        private function crashAlertDismiss(buttonIndex:int, userDescription:String):void
        {
            var metaData:FPCrashMetaData = new FPCrashMetaData(userDescription, 'usrName', 'usrEmail', 'urdId');
            var res:Boolean;
            switch (buttonIndex) {
                case 0:
                    addLog('handleUserInput:CANCEL');
                    break;
                case 1:
                    addLog('handleUserInput:SEND');
                    res = FPHockeyApp.manager.crash.handleUserInput(FPCrashManagerUserInput.SEND, metaData);
                    addLog('	res:'+res);
                    break;
                case 2:
                    addLog('handleUserInput:ALWAYS_SEND');
                    res = FPHockeyApp.manager.crash.handleUserInput(FPCrashManagerUserInput.ALWAYS_SEND, metaData);
                    addLog('	res:'+res);
                    break;
            }
        }

        private function addLog(...message):void
        {
            var string:String = message.join('	')+'\n';
            log.appendText(string);
            log.scrollV = log.maxScrollV;
        }

        private function socViewAction(event:PanelEvent):void
        {
            switch (event.socId) {
                case 'Base':
                    baseAction(event.buttonId);
                    break;
                case 'Authenticator':
                    authenticatorAction(event.buttonId);
                    break;
                case 'Feedback':
                    feedbackAction(event.buttonId);
                    break;
                case 'Crash':
                    crashAction(event.buttonId);
                    break;
            }
        }

        private function baseAction(id:String):void
        {
            switch (id) {
                case 'configureWithIdentifier':
                    FPHockeyApp.manager.configureWithIdentifier(LIVE_ID);
                    addLog('configureWithIdentifier:'+LIVE_ID);
                    break;
                case 'startManager':
                    addLog('startManager');
                    FPHockeyApp.manager.startManager();
                    //
                    addLog('lastSessionCrashDetails:\n	'+FPHockeyApp.manager.crash.lastSessionCrashDetails);
                    addLog('didCrashInLastSession:	'+FPHockeyApp.manager.crash.didCrashInLastSession);
                    addLog('didReceiveMemoryWarningInLastSession:	'+FPHockeyApp.manager.crash.didReceiveMemoryWarningInLastSession);
                    break;
                case 'start beta':
                    addLog('start beta');
                    FPHockeyApp.manager.configureWithBetaIdentifier(BETA_ID, LIVE_ID);
                    FPHockeyApp.manager.authenticator.identificationType = FPAuthenticatorIdentificationType.ANONYMOUS;
                    FPHockeyApp.manager.startManager();
                    FPHockeyApp.manager.authenticator.authenticateInstallation();
                    //
                    addLog('lastSessionCrashDetails:\n	'+FPHockeyApp.manager.crash.lastSessionCrashDetails);
                    addLog('didCrashInLastSession:	'+FPHockeyApp.manager.crash.didCrashInLastSession);
                    addLog('didReceiveMemoryWarningInLastSession:	'+FPHockeyApp.manager.crash.didReceiveMemoryWarningInLastSession);
                    break;
                case 'use live id':
                    FPHockeyApp.manager.shouldUseLiveIdentifier = true;
                    break;
                case 'start anonymous':
                    addLog('start anonymous');
                    FPHockeyApp.manager.configureWithIdentifier(LIVE_ID);
                    FPHockeyApp.manager.startManager();
                    FPHockeyApp.manager.authenticator.authenticateInstallation();
                    //
                    addLog('lastSessionCrashDetails:\n	'+FPHockeyApp.manager.crash.lastSessionCrashDetails);
                    addLog('didCrashInLastSession:	'+FPHockeyApp.manager.crash.didCrashInLastSession);
                    addLog('didReceiveMemoryWarningInLastSession:	'+FPHockeyApp.manager.crash.didReceiveMemoryWarningInLastSession);
                    break;
                case 'start ha user':
                    addLog('start ha user');
                    FPHockeyApp.manager.configureWithIdentifier(LIVE_ID);
                    FPHockeyApp.manager.authenticator.identificationType = FPAuthenticatorIdentificationType.HOCKEY_APP_USER;
                    FPHockeyApp.manager.startManager();
                    FPHockeyApp.manager.authenticator.authenticateInstallation();
                    break;
                case 'start device':
                    addLog('start device');
                    FPHockeyApp.manager.authenticator.identificationType = FPAuthenticatorIdentificationType.DEVICE;
                    FPHockeyApp.manager.configureWithIdentifier(LIVE_ID);
                    FPHockeyApp.manager.startManager();
                    FPHockeyApp.manager.authenticator.authenticateInstallation();
                    break;
                case 'handleUserInput':
                    addLog('handleUserInput');
                    var res:Boolean = FPHockeyApp.manager.crash.handleUserInput(FPCrashManagerUserInput.SEND, new FPCrashMetaData('Описание', 'Серьезный Сем', 'mail@mail.ru', '111'));
                    addLog('	res:'+res);
                    break;
                case 'serverUrl':
                    addLog('serverUrl: '+FPHockeyApp.manager.serverURL);
                    break;
                case 'disableCrashManager':
                    FPHockeyApp.manager.disableCrashManager = !FPHockeyApp.manager.disableCrashManager;
                    addLog('disableCrashManager: '+FPHockeyApp.manager.disableCrashManager);
                    break;
                case 'disableFeedbackManager':
                    FPHockeyApp.manager.disableFeedbackManager = !FPHockeyApp.manager.disableFeedbackManager;
                    addLog('disableFeedbackManager: '+FPHockeyApp.manager.disableFeedbackManager);
                    break;
                case 'appEnvironment':
                    addLog('appEnvironment: '+FPHockeyApp.manager.appEnvironment);
                    break;
                case 'installString':
                    addLog('installString: '+FPHockeyApp.manager.installString);
                    break;
                case 'debugLogEnabled':
                    FPHockeyApp.manager.debugLogEnabled = !FPHockeyApp.manager.debugLogEnabled;
                    addLog('debugLogEnabled: '+FPHockeyApp.manager.debugLogEnabled);
                    break;
                case 'testIdentifier':
                    addLog('testIdentifier');
                    FPHockeyApp.manager.testIdentifier()
                    break;
                case 'default user':
                    addLog('default user');
                    FPHockeyApp.manager.defaultUser = new FPhaUserData('1', 'UserDefault');
                    FPHockeyApp.manager.defaultUserFeedback = new FPhaUserData('2', 'UserFeedback');
                    FPHockeyApp.manager.defaultUserCrash = new FPhaUserData('3', 'UserCrash', 'test@mail.ru');
                    break;
                case 'userName':
                    addLog('userName:'+FPHockeyApp.manager);
                    break;
                //
                case 'test':
                    addLog('test');
                    var testRes:* = FPHockeyApp.manager._testCall();
                    trace(testRes);
                    addLog('	res:'+testRes);
                    break;
                case 'test_crash':
                    FPHockeyApp.manager._testCall('crash');
                    break;
            }
        }

        private function authenticatorAction(id:String):void
        {
            switch (id) {
                case 'authenticateInstallation':
                    addLog('authenticateInstallation');
                    FPHockeyApp.manager.authenticator.authenticateInstallation();
                    break;
                case 'restrictApplicationUsage':
                    addLog('restrictApplicationUsage:'+FPHockeyApp.manager.authenticator.restrictApplicationUsage);
                    break;
                case 'restrictionEnforcementFrequency':
                    addLog('restrictionEnforcementFrequency:'+FPHockeyApp.manager.authenticator.restrictionEnforcementFrequency);
                    break;
                case 'webpageURL':
                    addLog('webpageURL:', FPHockeyApp.manager.authenticator.webpageURL);
                    break;
                case 'deviceAuthenticationURL':
                    addLog('deviceAuthenticationURL:', FPHockeyApp.manager.authenticator.deviceAuthenticationURL());
                    break;
                case 'urlScheme':
                    addLog('urlScheme:', FPHockeyApp.manager.authenticator.urlScheme);
                    break;
                case 'identifyWithCompletion':
                    addLog('identifyWithCompletion:', FPHockeyApp.manager.authenticator.identifyWithCompletion());
                    break;
                case 'identified':
                    addLog('identified:', FPHockeyApp.manager.authenticator.identified);
                    break;
                case 'validateWithCompletion':
                    addLog('validateWithCompletion:', FPHockeyApp.manager.authenticator.validateWithCompletion());
                    break;
                case 'validated':
                    addLog('validated:', FPHockeyApp.manager.authenticator.validated);
                    break;
                case 'cleanupInternalStorage':
                    addLog('cleanupInternalStorage');
                    FPHockeyApp.manager.authenticator.cleanupInternalStorage();
                    break;
                case 'publicInstallationIdentifier':
                    addLog('publicInstallationIdentifier:'+FPHockeyApp.manager.authenticator.publicInstallationIdentifier());;
                    break;
            }
        }

        private function feedbackAction(id:String):void
        {
            switch (id) {
                case 'sample':
                    addLog('sample');
                    FPHockeyApp.manager.feedback.showFeedbackComposeView();
                    break;
                case 'with items':
                    addLog('with items');
                    showFeedBackWithItems();
                    break;
                case 'with screenshot':
                    addLog('with screenshot');
                    FPHockeyApp.manager.feedback.showFeedbackComposeViewWithGeneratedScreenshot();
                    break;
                case 'feedback list':
                    addLog('feedback list');
                    FPHockeyApp.manager.feedback.showFeedbackListView();
                    break;
                case 'showFirstRequiredPresentationModal':
                    FPHockeyApp.manager.feedback.showFirstRequiredPresentationModal = !FPHockeyApp.manager.feedback.showFirstRequiredPresentationModal;
                    addLog('showFirstRequiredPresentationModal:'+FPHockeyApp.manager.feedback.showFirstRequiredPresentationModal);
                    break;
                case 'hideImageAttachmentButton':
                    FPHockeyApp.manager.feedback.hideImageAttachmentButton = !FPHockeyApp.manager.feedback.hideImageAttachmentButton;
                    addLog('hideImageAttachmentButton:'+FPHockeyApp.manager.feedback.hideImageAttachmentButton);
                    break;
            }
        }
        private function showFeedBackWithItems():void
        {
            //FPHockeyApp.instance._testCall();
            var image:BitmapData = new BitmapData(100, 100, false, 0xffffffff);
            image.noise(100000*Math.random());
            var bytes:ByteArray = PNGEncoder.encode(image);
            var attachData:FPhaAttachmentBytes = new FPhaAttachmentBytes(bytes, 'screen.png', 'application/octet-stream');
            //
            var file:File = File.applicationStorageDirectory.resolvePath('file.png');
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.WRITE);
            stream.writeBytes(bytes);
            stream.close();
            var attachFile:FPhaAttachmentFile = new FPhaAttachmentFile(file.nativePath, 'file.png', 'application/octet-stream');
            //
            FPHockeyApp.manager.feedback.showFeedbackComposeViewWithPreparedItems('Тестирование FPhaAttachmentData', attachFile);
        }

        private function crashAction(id:String):void
        {
            switch (id) {
                case 'generateTestCrash':
                    addLog('generateTestCrash');
                    FPHockeyApp.manager.crash.generateTestCrash();
                    break;
                case 'showAlwaysButton':
                    FPHockeyApp.manager.crash.showAlwaysButton = !FPHockeyApp.manager.crash.showAlwaysButton;
                    addLog('showAlwaysButton = ', FPHockeyApp.manager.crash.showAlwaysButton);
                    break;
                case 'status DISABLED':
                    addLog('status DISABLED');
                    FPHockeyApp.manager.crash.crashManagerStatus = FPCrashManagerStatus.DISABLED;
                    break;
                case 'status ALWAYS_ASK':
                    addLog('status ALWAYS_ASK');
                    FPHockeyApp.manager.crash.crashManagerStatus = FPCrashManagerStatus.ALWAYS_ASK;
                    break;
                case 'status AUTO_SEND':
                    addLog('status AUTO_SEND');
                    FPHockeyApp.manager.crash.crashManagerStatus = FPCrashManagerStatus.AUTO_SEND;
                    break;
                case 'setAlertViewHandler':
                    addLog('setAlertViewHandler');
                    FPHockeyApp.manager.crash.setAlertViewHandler();
                    break;
                case 'showAlertView':
                    addLog('showAlertView');
                    FPHockeyApp.manager.crash.showAlertView('Что то пошло не так :(', ' отправить логи?', 'не надо', 'отправить ', 'больше не спрашивать', true);
                    break;
            }
        }
    }
}