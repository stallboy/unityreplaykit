using System.Runtime.InteropServices;

namespace AReplayKit
{
    public static class Broadcast
    {
#if UNITY_IOS && !UNITY_EDITOR

        public static void LoadAndPresent()
        {
            rpbroadcast_LoadAndPresent();
        }


        public static void StartBroadcast()
        {
            rpbroadcast_StartBroadcast();
        }

        public static void FinishBroadcast()
        {
            rpbroadcast_FinishRecording();
        }

        public static bool IsBroadcasting()
        {
            return rpbroadcast_IsBroadcasting() > 0;
        }


        public static void PauseBroadcast()
        {
            rpbroadcast_PauseBroadcast();
        }

        public static void ResumeBroadcast()
        {
            rpbroadcast_ResumeBroadcast();
        }

        public static bool IsPaused()
        {
            return rpbroadcast_IsPaused() > 0;
        }


        public static string GetServiceInfo()
        {
            return rpbroadcast_GetServiceInfo();
        }


        [DllImport("__Internal")]
        private static extern void rpbroadcast_LoadAndPresent();


        [DllImport("__Internal")]
        private static extern void rpbroadcast_StartBroadcast();

        [DllImport("__Internal")]
        private static extern void rpbroadcast_FinishRecording();

        [DllImport("__Internal")]
        private static extern int rpbroadcast_IsBroadcasting();


        [DllImport("__Internal")]
        private static extern void rpbroadcast_PauseBroadcast();

        [DllImport("__Internal")]
        private static extern void rpbroadcast_ResumeBroadcast();

        [DllImport("__Internal")]
        private static extern int rpbroadcast_IsPaused();


        [DllImport("__Internal")]
        private static extern string rpbroadcast_GetServiceInfo();
#else
        public static void LoadAndPresent()
        {
        }


        public static void StartBroadcast()
        {
        }

        public static void FinishBroadcast()
        {
        }

        public static bool IsBroadcasting()
        {
            return false;
        }


        public static void PauseBroadcast()
        {
        }

        public static void ResumeBroadcast()
        {
        }

        public static bool IsPaused()
        {
            return false;
        }


        public static string GetServiceInfo()
        {
            return null;
        }
#endif
    }
}