package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	v1 "k8s.io/api/admission/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func validateDeployment(w http.ResponseWriter, r *http.Request) {
	decoder := json.NewDecoder(r.Body)
	var admissionReviewReq v1.AdmissionReview
	err := decoder.Decode(&admissionReviewReq)
	if err != nil {
		log.Printf("Failed to decode admission review request: %v", err)
		http.Error(w, fmt.Sprintf("Failed to decode admission review request: %v", err), http.StatusBadRequest)
		return
	}

	admissionReviewResp := v1.AdmissionReview{
		TypeMeta: metav1.TypeMeta{
			Kind:       "AdmissionReview",
			APIVersion: "admission.k8s.io/v1",
		},
	}

	// Extract the Pod object from the admission review request
	rawPod := admissionReviewReq.Request.Object.Raw
	pod := corev1.Pod{}
	err = json.Unmarshal(rawPod, &pod)
	if err != nil {
		log.Printf("Failed to unmarshal pod object: %v", err)
		admissionReviewResp.Response = &v1.AdmissionResponse{
			Result: &metav1.Status{
				Message: fmt.Sprintf("Failed to unmarshal pod object: %v", err),
			},
		}
		encodeResponse(w, admissionReviewResp)
		return
	}

	// Check if the Pod's resource requests are specified
	if pod.Spec.Containers != nil {
		for _, container := range pod.Spec.Containers {
			if container.Resources.Requests == nil {
				admissionReviewResp.Response = &v1.AdmissionResponse{
					Result: &metav1.Status{
						Message: "Resource requests are not specified",
					},
					Allowed: false,
				}
				encodeResponse(w, admissionReviewResp)
				return
			}
		}
	}

	// If resource requests are specified or the Pod does not have containers, allow the Pod
	admissionReviewResp.Response = &v1.AdmissionResponse{
		Allowed: true,
	}
	encodeResponse(w, admissionReviewResp)
}

func encodeResponse(w http.ResponseWriter, response v1.AdmissionReview) {
	encoder := json.NewEncoder(w)
	err := encoder.Encode(response)
	if err != nil {
		log.Printf("Failed to encode admission review response: %v", err)
		http.Error(w, fmt.Sprintf("Failed to encode admission review response: %v", err), http.StatusInternalServerError)
		return
	}
}

func main() {
	http.HandleFunc("/validate", validateDeployment)
	log.Println("Starting webhook server...")
	http.ListenAndServeTLS(":8443", "cert.pem", "key.pem", nil)
}
