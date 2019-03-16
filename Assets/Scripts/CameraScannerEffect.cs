using System.Collections;
using UnityEngine;

public class CameraScannerEffect : MonoBehaviour
{
    private Material m_material = null;
    [SerializeField, Range(0, 200)]
    private float m_scannerWidth = 5f;
    [SerializeField]
    private float m_speed = 0.03f;
    [SerializeField]
    private Color m_scanWaveColor = Color.red;

    void Awake()
    {
        m_material = new Material(Shader.Find("Hidden/Scanner"));
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            m_material.SetVector("_ScannerWorldSpacePosition", transform.position);
            m_material.SetVector("_ScannerWorldSpaceForwardDir", transform.forward);
            m_material.SetFloat("_ScannerWidth", m_scannerWidth);
            m_material.SetVector("_ScanWaveColor", m_scanWaveColor);
            CastScanWave();
        }
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, m_material);
    }

    private void CastScanWave()
    {
        StartCoroutine(IncreaseScanWaveDistance());
    }

    private IEnumerator IncreaseScanWaveDistance()
    {
        float start = 0f;
        float end = 2 * transform.GetComponent<Camera>().farClipPlane;
        float step = 0f;

        while (step < 1f)
        {
            step += Time.deltaTime * m_speed;
            float sonarDistance = Mathf.Lerp(start, end, step);
            m_material.SetFloat("_ScannerDistance", sonarDistance);
            yield return new WaitForEndOfFrame();
        }

        m_material.SetFloat("_ScannerDistance", 0f);
    }
}
