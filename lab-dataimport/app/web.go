package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"path/filepath"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/gorilla/mux"
)

func DownloadContent(region string, config *aws.Config, bucket_name string, item string) (int64, error) {

	sess_download, err := session.NewSessionWithOptions(session.Options{

		Config: aws.Config{
			Region:      aws.String(region),
			Credentials: config.Credentials,
		},
	})

	downloader := s3manager.NewDownloader(sess_download)
	file, err := os.Create(filepath.Join("./data-storage/", filepath.Base(item)))

	numBytes, err := downloader.Download(file,
		&s3.GetObjectInput{
			Bucket: aws.String(bucket_name),
			Key:    aws.String(item),
		})

	if err != nil {
		fmt.Println("Error DownloadContent", err)
		return 0, err
	}

	fmt.Println("Downloaded", file.Name(), numBytes, "bytes")
	return numBytes, nil

}

func GetListObjects(sess *session.Session, config *aws.Config, bucket_name string) (*s3.ListObjectsV2Output, error) {

	//initilize or re-initilize the S3 client
	S3svc := s3.New(sess, config)

	result, err := S3svc.ListObjectsV2(&s3.ListObjectsV2Input{Bucket: aws.String(bucket_name)})

	if err != nil {
		fmt.Println(bucket_name)
		return result, err
	}

	return result, nil
}

// Request GET
func listData(w http.ResponseWriter, r *http.Request) {
	type Files struct {
		Filename string `json:"file_name"`
		Size     int64  `json:"size"`
	}

	files, err := ioutil.ReadDir("./data-storage/")
	if err != nil {
		http.Error(w, "Internal server error", 500)
		return
	}

	var files_list []Files
	for _, file := range files {
		files_list = append(files_list, Files{Filename: file.Name(), Size: file.Size()})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(files_list)
}

// Request POST /importData
func importData(w http.ResponseWriter, r *http.Request) {

	type ImportData struct {
		BucketName string `json: "bucket_name"`
		AccessKey  string `json: "access_key"`
		SecretKey  string `json: "secret_key"`
		Region     string `json: "regions_select"`
	}

	reqBody, _ := ioutil.ReadAll(r.Body)
	var imptdata ImportData
	json.Unmarshal(reqBody, &imptdata)

	//session object initialization
	session_init, err := session.NewSession(&aws.Config{
		Region: &imptdata.Region},
	)
	if err != nil {
		json.NewEncoder(w).Encode(err)
	}

	//*aws config initialization
	aws_config := &aws.Config{}

	if len(imptdata.AccessKey) == 0 || len(imptdata.SecretKey) == 0 {
		fmt.Println("Using nil value for Credentials")
		aws_config.Credentials = nil
	} else {
		fmt.Println("Using NewStaticCredentials")
		aws_config.Credentials = credentials.NewStaticCredentials(imptdata.AccessKey, imptdata.SecretKey, "")
	}

	//list of all objects
	allObjects, err := GetListObjects(session_init, aws_config, *aws.String(imptdata.BucketName))

	if err != nil {
		http.Error(w, err.Error(), 500)
	}

	for _, d := range allObjects.Contents {
		fmt.Println("Downloading", *d.Key)
		_, err := DownloadContent(imptdata.Region, aws_config, imptdata.BucketName, *d.Key)
		if err != nil {
			http.Error(w, err.Error(), 500)
		}
	}

	json.NewEncoder(w).Encode(allObjects)
}

// Request GET /reset-challenge
func resetChallenge(w http.ResponseWriter, r *http.Request) {

	fmt.Println("Endpoint /reset-challenge called")

	eDummy := os.Remove(filepath.Join("./data-storage/", "dummy.txt"))
	if eDummy != nil {
		json.NewEncoder(w).Encode("Error deleting dummy.txt")
	}

	eKeys := os.Remove(filepath.Join("./data-storage/", "keys.txt"))
	if eKeys != nil {
		json.NewEncoder(w).Encode("Error deleting keys.txt")
	}

	json.NewEncoder(w).Encode("Challenge reset ok")

}

// Request GET /variable
func varBucketName(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint /variable called")
	json.NewEncoder(w).Encode(os.Getenv("BUCKET_NAME"))
}

func main() {

	router := mux.NewRouter().StrictSlash(true)

	router.HandleFunc("/importData", importData).Methods("POST")
	router.HandleFunc("/getListFiles", listData).Methods("GET")
	router.HandleFunc("/variable", varBucketName).Methods("GET")
	router.HandleFunc("/reset-challenge", resetChallenge).Methods("GET")

	s := http.StripPrefix("/storage/", http.FileServer(http.Dir("./data-storage/")))
	router.PathPrefix("/storage/").Handler(s)

	//index.html and frontend assets
	router.PathPrefix("/").Handler(http.FileServer(http.Dir("./frontend/")))

	log.Fatal(http.ListenAndServe(":80", router))
}
