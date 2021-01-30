#include "GL/freeglut.h" 

void init();
void display();
void drawPoints();
void keyboard(unsigned char key, int x, int y);

void drawPoints(){
	glClear(GL_COLOR_BUFFER_BIT);
	glColor3f(1.0, 1.0, 1.0);
	glBegin(GL_POLYGON);
	glVertex2f(-0.5, 0.0);
	glVertex2f(0.5, 0.0);
	glVertex2f(0.0, 1.0);
	glEnd();
	glFlush();
}

void keyboard(unsigned char key, int x, int y){
	switch(key){
		case 'q':
		case 'Q':
			exit(EXIT_SUCCESS);
			break;
		case 'r' :
		case 'R' :
			glClearColor(1.0, 0.0, 0.0, 1.0);
			break;
	}
	glutPostRedisplay();

}

int main(int argc, char **argv) {
	int mode = GLUT_RGB | GLUT_SINGLE;
		
	// GLUT_RGB : True Color Mode
	// GLUT_DOUBLE : Use Double Buffer
	// Default Mode : GLUT_RGB | GLUT_SINGLE

	// Init GLUT & create Window
	glutInit(&argc, argv);
	glutInitDisplayMode(mode);	// Set drawing surface property
	glutInitWindowPosition(100, 100);	// Set window Position at Screen
	glutInitWindowSize(400,400);	// Set window size. Set printed working area size. Bigger than this size
	glutCreateWindow("OpenGL");	// Generate window. argument is window's name
	glutSetWindowTitle("exam");
	
	// Register Callback function before set glutMainLoop()
	glutDisplayFunc(drawPoints);
	glutKeyboardFunc(keyboard);
	glutMainLoop();	// Monitor message queue and Run the corresponding callback function
    return 1;
}