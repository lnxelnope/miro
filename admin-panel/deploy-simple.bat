@echo off
REM Deploy Admin Panel to Cloud Run (Simple version - no commit SHA)
REM Run this from the admin-panel directory

echo ================================================
echo  Deploying MiRO Admin Panel to Cloud Run
echo ================================================
echo.

echo Using tag: latest
echo.

REM Run gcloud build submit with simple config
gcloud builds submit --config=cloudbuild-simple.yaml .

echo.
echo ================================================
echo  Deployment complete!
echo  Check Cloud Run: https://console.cloud.google.com/run?project=miro-d6856
echo ================================================
