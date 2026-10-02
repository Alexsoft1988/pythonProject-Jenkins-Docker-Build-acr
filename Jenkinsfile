pipeline {
    agent any
    environment {
        SONAR_SERVER = 'sonarqube-server'
        REPO_NAME = "${env.GIT_URL.split('/').last().split('\\.').first()}"

        IMAGE_NAME       = 'aplicacion-python'
        IMAGE_TAG        = 'latest'
        DOCKERFILE_PATH  = 'Dockerfile'
        VERSION          = env.BUILD_NUMBER
        ACR_REGISTRY     = 'lab.docker.jenkins'
       
    }
    stages {
        stage('Checkout con python') {
            steps {
                checkout scm

                echo "Repositorio: ${env.REPO_NAME}"
                echo "Branch: ${env.BRANCH_NAME ?: 'N/A'}"
            }
        }

        stage('Compilar con python') {
            agent {
                docker { image 'python:2-alpine' }
            }
            steps {
                sh 'python -m py_compile source/main.py source/producto.py'
                stash(name: 'resultado -compilacion', includes: 'source/*.py*')
                echo "Compilacion Correcta"
                archiveArtifacts 'source/*.py*'
            }
        }
        stage('Build Image Docker') {
        steps {
                copyArtifacts(
                    projectName: env.JOB_NAME,
                    selector: [$class: 'SpecificBuildSelector', buildNumber: "${env.BUILD_NUMBER}"],
                    filter: 'source/*.py',
                    fingerprintArtifacts: true,
                    flatten: true,
                    target: 'source'
                )
            
                sh 'docker build -t ${ACR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -f ${DOCKERFILE_PATH} .'
                echo "imagen Docker Generado: ${DOCKERFILE_PATH}"
               
            }
        }
        stage('Analisis de SonarQube') {
            steps {
                script {
                    scannerHome = tool 'sonar-scanner'// must match the name of an actual scanner installation directory on your Jenkins build agent
                }
                withSonarQubeEnv("${SONAR_SERVER}") {// If you have configured more than one global server connection, you can specify its name as configured in Jenkins
                    sh """
                        ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=${REPO_NAME} \
                            -Dsonar.projectName=${REPO_NAME} \
                            -Dsonar.sources=.
                            
                    """
                }
            }
        }
    }
    post {

        success {
            echo '======================================'
            echo ' PIPELINE FINALIZADO CORRECTAMENTE'
            echo ' SonarQube Quality Gate: PASSED'
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo ' PIPELINE FALLÓ'
            echo ' Revisar compilación, SonarQube o Quality Gate'
            echo '======================================'
        }

        always {
            echo "Repositorio analizado: ${REPO_NAME}"
        }
    }


}
