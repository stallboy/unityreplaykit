using System.Runtime.InteropServices;

namespace AReplayKit
{
    public static class ScreenRecorder
    {

#if UNITY_IOS && !UNITY_EDITOR

        public static bool IsAvailable()
        {
            return true;
        }

        public static void StartRecording()
        {
            rpscreenrecorder_StartRecording();
        }

        public static void StopRecording()
        {
            rpscreenrecorder_StopRecording();
        }

        public static void DiscardRecording()
        {
            rpscreenrecorder_DiscardRecording();
        }
        
        public static bool IsRecording()
        {
            return rpscreenrecorder_IsRecording() > 0;
        }



        public static bool CanPreview()
        {
            return rpscreenrecorder_CanPreview() > 0;
        }

        public static void Preview()
        {
            rpscreenrecorder_Preview();
        }


        public static void SetCameraPreviewPositionAndSize(int top, int left, int width, int height)
        {
            rpscreenrecorder_SetCameraPreviewPositionAndSize(top, left, width, height);
        }

        public static void SetCameraEnabled(bool enable)
        {
            rpscreenrecorder_SetCameraEnabled(enable ? 1 : 0);
        }

        public static bool IsCameraEnabled()
        {
            return rpscreenrecorder_IsCameraEnabled() > 0;
        }

        public static void SetMicrophoneEnabled(bool enable)
        {
            rpscreenrecorder_SetMicrophoneEnabled(enable ? 1 : 0);
        }

        public static bool IsMicrophoneEnabled()
        {
            return rpscreenrecorder_IsMicrophoneEnabled() > 0;
        }
        

        [DllImport("__Internal")]
        private static extern void rpscreenrecorder_StartRecording();

        [DllImport("__Internal")]
        private static extern void rpscreenrecorder_StopRecording();

        [DllImport("__Internal")]
        private static extern void rpscreenrecorder_DiscardRecording();

        [DllImport("__Internal")]
        private static extern int rpscreenrecorder_IsRecording();


        [DllImport("__Internal")]
        private static extern int rpscreenrecorder_CanPreview();

        [DllImport("__Internal")]
        private static extern void rpscreenrecorder_Preview();


        [DllImport("__Internal")]
        private static extern void rpscreenrecorder_SetCameraPreviewPositionAndSize(int top, int left, int width,
            int height);

        [DllImport("__Internal")]
        private static extern void rpscreenrecorder_SetCameraEnabled(int enable);

        [DllImport("__Internal")]
        private static extern int rpscreenrecorder_IsCameraEnabled();



        [DllImport("__Internal")]
        private static extern void rpscreenrecorder_SetMicrophoneEnabled(int enable);

        [DllImport("__Internal")]
        private static extern int rpscreenrecorder_IsMicrophoneEnabled();


#else
        public static bool IsAvailable()
        {
            return false;
        }

        public static void StartRecording()
        {
        }

        public static void StopRecording()
        {
        }

        public static void DiscardRecording()
        {
        }

        public static bool IsRecording()
        {
            return false;
        }


        public static bool CanPreview()
        {
            return false;
        }

        //在not IsRecording 和 canPreview的时候再来Preview，要不然是黑屏的
        public static void Preview()
        {
        }


        public static void SetCameraPreviewPositionAndSize(int left, int top, int width, int height)
        {
        }

        public static void SetCameraEnabled(bool enable)
        {
        }

        public static bool IsCameraEnabled()
        {
            return false;
        }

        public static void SetMicrophoneEnabled(bool enable)
        {
        }

        public static bool IsMicrophoneEnabled()
        {
            return false;
        }

#endif
    }
}