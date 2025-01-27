node{
  def mavenHome = tool name: 'maven3.9.6'    
  stage('1.clonecode'){
    git "https://github.com/LandmakTechnology/maven-web-application"
  }
  stage('2.mavenBuild'){
    sh "${mavenHome}/bin/mvn package"
  }
  stage('3.codeQualityAnalysis'){
    sh "${mavenHome}/bin/mvn sonar:sonar" 
   //edit pom.xml propertiesTAG with SonarQube server details
  }
  stage('4.uploadArtifacts'){
    sh "${mavenHome}/bin/mvn deploy"
  }
  stage('5.deploy2UAT'){
    //use deploy to container plugin
    deploy adapters: [tomcat9(credentialsId: 'tomcat-credentials', path: '', url: 'http://3.144.85.2:8088/')], contextPath: null, war: 'target/*war'
 }
  stage('6.ManualApproval'){
    sh " echo 'Please review & approve' "
    timeout(time:300, unit:'MINUTES')
    {
      input message: 'Application ready for deployment, Please review and approve'
    }       
  }
  stage('7.deploy2prod'){
    //use deploy to container plugin
    deploy adapters: [tomcat9(credentialsId: 'tomcat-credentials', path: '', url: 'http://3.144.85.2:8088/')], contextPath: null, war: 'target/*war'    
  }

  stage('8.apm'){
    sh "echo 'monitoring and observation and alerting' "
    sh "echo 'application performance Monitoring in progress' "
  }
  stage('9.notification'){
    sh "echo create email notification to resolve any issue that may arise"
    //use pipeline syntax and email notification plugin to achieve this  
    emailext body: '''The build and Deployment status for tesla-webapp.
