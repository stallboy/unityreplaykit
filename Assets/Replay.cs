using System.Collections.Generic;
using AReplayKit;
using UnityEngine;

public class Replay : IReplayKitCallback
{
    private string lasttxt;
    private readonly List<string> listinfos = new List<string>();

    void OnGUI()
    {
        GUI.Label(lablerc(0), lasttxt);
        int i = 2;
        foreach (var inf in listinfos)
        {
            GUI.Label(lablerc(i), inf);
            i++;
        }


        if (!ScreenRecorder.IsAvailable())
        {
            if (GUI.Button(rc(3, 0), "以上按钮都没用"))
            {
                set("test", "hello");
            }
        }

        // 录屏
        if (!ScreenRecorder.IsRecording())
        {
            if (GUI.Button(rc(0, 0), "StartRecording"))
            {
                ScreenRecorder.StartRecording();
            }
        }
        else
        {
            if (GUI.Button(rc(0, 0), "StopRecording"))
            {
                ScreenRecorder.StopRecording();
            }
        }


        if (!ScreenRecorder.IsCameraEnabled())
        {
            if (GUI.Button(rc(0, 1), "EnableCamera"))
            {
                ScreenRecorder.SetCameraEnabled(true);
            }
        }
        else
        {
            if (GUI.Button(rc(0, 1), "DisableCamera"))
            {
                ScreenRecorder.SetCameraEnabled(false);
            }
        }

        if (!ScreenRecorder.IsMicrophoneEnabled())
        {
            if (GUI.Button(rc(0, 2), "EnableMicrophone"))
            {
                ScreenRecorder.SetMicrophoneEnabled(true);
            }
        }
        else
        {
            if (GUI.Button(rc(0, 2), "DisableMicrophone"))
            {
                ScreenRecorder.SetMicrophoneEnabled(false);
            }
        }

        // 预览
        if (ScreenRecorder.CanPreview())
        {
            if (GUI.Button(rc(1, 0), "DiscardRecording"))
            {
                ScreenRecorder.DiscardRecording();
            }
            if (GUI.Button(rc(1, 1), "Preview"))
            {
                ScreenRecorder.Preview();
            }
        }


        // 广播
        if (GUI.Button(rc(2, 0), "LoadAndPresent"))
        {
            Broadcast.LoadAndPresent();
        }


        if (!Broadcast.IsBroadcasting())
        {
            if (GUI.Button(rc(2, 1), "StartBroadcast"))
            {
                Broadcast.StartBroadcast();
            }
        }
        else
        {
            if (GUI.Button(rc(2, 1), "FinishBroadcast"))
            {
                Broadcast.FinishBroadcast();
            }
        }

        if (Broadcast.IsBroadcasting())
        {
            if (!Broadcast.IsPaused())
            {
                if (GUI.Button(rc(2, 2), "PauseBroadcast"))
                {
                    Broadcast.PauseBroadcast();
                }
            }
            else
            {
                if (GUI.Button(rc(2, 2), "ResumeBroadcast"))
                {
                    Broadcast.ResumeBroadcast();
                }
            }
        }

        // 其他
        if (GUI.Button(rc(3, 0), "SetCameraPreviewPositionAndSize"))
        {
            int w = Random.Range(0, 50);
            int h = Random.Range(0, 50);
            ScreenRecorder.SetCameraPreviewPositionAndSize(Screen.width - 310 - w, Screen.height - 420 - h, 300, 300);
        }

        if (GUI.Button(rc(3, 1), "GetServiceInfo"))
        {
            set("GetServiceInfo", Broadcast.GetServiceInfo());
        }
    }

    private static Rect lablerc(int r)
    {
        return new Rect(10, 300 + r*30, 600, 24);
    }

    private static Rect rc(int row, int col)
    {
        return new Rect(20 + col*240, 20 + row*60, 200, 40);
    }

    private void set(string funcName, string info)
    {
        lasttxt = funcName + ": " + info;
        Debug.Log(lasttxt);
        listinfos.Add(lasttxt);

        if (listinfos.Count > 20)
        {
            listinfos.RemoveAt(0);
        }
    }

    public override void ScreenRecorder_StartRecordingComplete(string err)
    {
        set("StartRecordingComplete", err);
    }

    public override void ScreenRecorder_StopRecordingComplete(string err)
    {
        set("StopRecordingComplete", err);
    }

    public override void ScreenRecorder_DiscardRecordingComplete(string err)
    {
        set("DiscardRecordingComplete", err);
    }

    public override void ScreenRecorder_EnableCameraComplete(string err)
    {
        set("ScreenRecorder_EnableCameraComplete", err);
    }

    public override void ScreenRecorder_EnableMicrophoneComplete(string err)
    {
        set("ScreenRecorder_EnableCameraComplete", err);
    }

    public override void ScreenRecorder_DidStopRecordingWithError(string err)
    {
        set("DidStopRecordingWithError", err);
    }

    public override void ScreenRecorder_PreviewControllerDidFinish(string _)
    {
        set("PreviewControllerDidFinish", _);
    }

    public override void BroadcastActivityViewController_LoadComplete(string err)
    {
        set("BroadcastViewLoadComplete", err);
    }

    public override void BroadcastActivityViewController_DidFinish(string err)
    {
        set("BroadcastViewDidFinish", err);
    }

    public override void Broadcast_StartBroadcastComplete(string err)
    {
        set("StartBroadcastComplete", err);
    }

    public override void Broadcast_FinishBroadcastComplete(string err)
    {
        set("FinishBroadcastComplete", err);
    }

    public override void BroadcastController_DidFinishWithError(string err)
    {
        set("BroadcastDidFinishWithError", err);
    }

    public override void BroadcastController_DidUpdateServiceInfo(string info)
    {
        set("BroadcastDidUpdateServiceInfo", info);
    }

    public override void DebugLog(string loginfo)
    {
        set("DebugLog", loginfo);
    }
}