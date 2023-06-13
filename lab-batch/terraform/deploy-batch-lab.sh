#!/usr/bin/env bash
terraform init
terraform apply -auto-approve
sleep 40
SERVICE_NAME="pill-batch"
TASK_ARN=$(aws ecs list-tasks --service-name "$SERVICE_NAME" --query 'taskArns[0]' --output text --cluster 'pills-ecs-cluster' --region us-east-1)
TASK_DETAILS=$(aws ecs describe-tasks --task "${TASK_ARN}" --query 'tasks[0].attachments[0].details' --cluster 'pills-ecs-cluster' --region us-east-1)
ENI=$(echo $TASK_DETAILS | jq -r '.[] | select(.name=="networkInterfaceId").value')
IP=$(aws ec2 describe-network-interfaces --network-interface-ids "${ENI}" --query 'NetworkInterfaces[0].Association.PublicIp' --output text --region us-east-1)
echo """
_________________________________________________________________________________________
_________ .__                   .____________           ___________.__    .______.   .__  __          
\_   ___ \|  |   ____  __ __  __| _/   _____/ ____   ___\__    ___/|__| __| _/\_ |__ |__|/  |_  ______
/    \  \/|  |  /  _ \|  |  \/ __ |\_____  \_/ __ \_/ ___\|    |   |  |/ __ |  | __ \|  \   __\/  ___/
\     \___|  |_(  <_> )  |  / /_/ |/        \  ___/\  \___|    |   |  / /_/ |  | \_\ \  ||  |  \___ \ 
 \______  /____/\____/|____/\____ /_______  /\___  >\___  >____|   |__\____ |  |___  /__||__| /____  >
        \/                       \/       \/     \/     \/                 \/      \/              \/ 
.___       _________   .____          ___.                                                            
|   |____  \_   ___ \  |    |   _____ \_ |__                                                          
|   \__  \ /    \  \/  |    |   \__  \ | __ \\                                                         
|   |/ __ \\     \____ |    |___ / __ \| \_\ \\                                                        
|___(____  /\______  / |_______ (____  /___  /                                                        
         \/        \/          \/    \/    \/                                                         
   _  _   ________                                                                                    
__| || |__\_____  \\                     Messing around                                                                 
\   __   /  _(__  <         -           with AWS Batch                                                                
 |  ||  |  /       \\                    For Privilege Escalations                                                                
/_  ~~  _\/______  /                                                                                  
  |_||_|         \/      
_________________________________________________________________________________________

Your Lab is deployed and ready.
Start hacking at :    http://$IP
"""
