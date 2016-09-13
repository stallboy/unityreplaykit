using UnityEngine;

public class Switch : MonoBehaviour {
	public GameObject a;
    public GameObject b;

    public bool aactive = true;

    void OnGUI()
	{
	    if (GUI.Button(new Rect(Screen.width - 260, Screen.height - 110, 250, 100), "switch obj"))
	    {
	        aactive = !aactive;
            a.SetActive(aactive);
            b.SetActive(!aactive);
	        
	    }
	}
}
