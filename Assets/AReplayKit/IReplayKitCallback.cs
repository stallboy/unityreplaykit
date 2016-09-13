using System.Runtime.InteropServices;
using UnityEngine;

namespace AReplayKit
{
    public abstract class IReplayKitCallback : MonoBehaviour
    {
#if UNITY_IOS && !UNITY_EDITOR
        public static void SetGameObjectName(string name)
        {
            replaykitcallback_SetGameObjectName(name);
        }

        [DllImport("__Internal")]
        private static extern void replaykitcallback_SetGameObjectName(string name);
#else
        public static void SetGameObjectName(string name)
        {
        }
#endif

        //////////////////////////// 录像接口

        //开始录像，完成或出错。
        //err 为空，表示成功, 第一次调用StartRecording，会弹出alert窗口让你确认的。
        public abstract void ScreenRecorder_StartRecordingComplete(string err);


        //停止录像，完成或出错。
        //err 为空，表示成功，preview view controller 成功返回被记录在ScreenRecorder里，然后可以ScreenRecorder.Preview了。
        public abstract void ScreenRecorder_StopRecordingComplete(string err);

        //删除录像，完成或出错。
        public abstract void ScreenRecorder_DiscardRecordingComplete(string err);

        //可能会弹出alert窗口来确认权限
        public abstract void ScreenRecorder_EnableCameraComplete(string err);
        public abstract void ScreenRecorder_EnableMicrophoneComplete(string err);

        //录像被停止，可能是录制过程中出错或屏幕录制不可用了，
        // recording stops due to an error or there is a change in recording availability
        public abstract void ScreenRecorder_DidStopRecordingWithError(string err);

        //录像预览窗口被关闭
        //Indicates the preview view controller dismissed.
        public abstract void ScreenRecorder_PreviewControllerDidFinish(string _);


        //////////////////////////// 广播

        //加载广播服务app列表，完成或出错
        public abstract void BroadcastActivityViewController_LoadComplete(string err);

        //完成广播服务app选择，完成或出错
        //如果err为nil，broadcastcontroller已经被缓存在Broadcast里，然后这里可以倒计时然后再StartBroadcast，或者直接StartBroadcast
        public abstract void BroadcastActivityViewController_DidFinish(string err);

        //开始广播，完成或出错
        public abstract void Broadcast_StartBroadcastComplete(string err);

        //终止广播，完成或出错
        public abstract void Broadcast_FinishBroadcastComplete(string err);

        //广播被终止, err可能为null
        public abstract void BroadcastController_DidFinishWithError(string err);

        //广播服务信息有更新
        public abstract void BroadcastController_DidUpdateServiceInfo(string info);


        //////////////////////////// 用于调试
        public abstract void DebugLog(string loginfo);
    }
}