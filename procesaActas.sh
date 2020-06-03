#!/bin/bash
################################################################################################
## Script creado por Vicente Martínez
## Este script extrae la información de las actas de evaluación (en formato PDF) a documentos CSV.
##
## Condiciones para que funcione el script
##  - El archivo tabula-1.0.2-jar-with-dependencies.jar tiene que estar dentro del subdirectorio libs/ScriptTabula
##  - Las actas que se procesan deben estar agrupados en carpetas por cursos
##    + Las actas de la evaluación ordinaria (Junio) deben estar en el subdirectorio ConvocatoriaOrdinaria
##    + Las actas de la evaluación extraordinaria (Julio) deben estar en el subdirectorio ConvocatoriaExtraordinaria
##
## ENTRADA
##
##  El programa recibe un parámetro de entrada (ordinaria | extraordinaria) para indicar qué actas se quieren procesar
##  Si no se indica ningún parámetro, por defecto se tomará el valor "ordinaria".
##
##  SALIDA
##
##  La salida del script son un conjunto de archivos CSV que contienen sólo las filas que cominezan por un número
##  Como resultado del procesamiento se obtiene un archivo CSV por nivel
##  Cada archivo CSV contiene una cabecera con la información de las asignaturas que que aparece en el PDF de las actas
##  Hay un grupo especial (PMAR 3ESOG) que requiere un postprocesamiento espcial al trabajar por ámbitos.
##
################################################################################################

# Obtenemos la convocatoria que se quiere procesar
if [ -n "$1" ]; then
  case $1 in
    Ordinaria) convocatoria="ConvocatoriaOrdinaria" ;;
    Extraordinaria) convocatoria="ConvocatoriaExtraordinaria" ;;
    *) convocatoria="ConvocatoriaOrdinaria"
  esac
else
  convocatoria="ConvocatoriaOrdinaria" 
fi

# Extract info for directories 1ESO, 2ESO, 3ESO, 4ESO
for ((i=1; i<=4; i++)); do

	# Courses can be 1ESO, 2ESO, 3ESO, 4ESO
	course=${i}ESO

	#Check if output file exists and delete it
	rm -f $convocatoria/Actas${course}.csv

	#Add headers to the CSV file based on level
	if [ $course == '1ESO' ]
	then
		echo "Curso,Grupo,Orden,Alumno,Repetidor,BG_CAL,BG_NOTA,GH_CAL,GH_NOTA,LCL_CAL,LCL_NOTA,MAT_CAL,MAT_NOTA,PLE,PLE_CAL,PLE_NOTA,EF_CAL,EF_NOTA,RELVE,RELVE_CAL,RELVE_NOTA,MUS_CAL,MUS_NOTA,TEC_CAL,TEC_NOTA,VLL_CAL,VLL_NOTA,LCA,LCA_CAL,LCA_NOTA" > $convocatoria/Actas${course}.csv
	fi

	if [ $course == '2ESO' ]
	then
		echo "Curso,Grupo,Orden,Alumno,Repetidor,PTE_1,FQ_CAL,FQ_NOTA,GH_CAL,GH_NOTA,LCL_CAL,LCL_NOTA,MAT_CAL,MAT_NOTA,PLE,PLE_CAL,PLE_NOTA,EF_CAL,EF_NOTA,RELVE,RELVE_CAL,RELVE_NOTA,MUS_CAL,MUS_NOTA,TEC_CAL,TEC_NOTA,EPVA_CAL,EPVA_NOTA,VLL_CAL,VLL_NOTA,LCA,LCA_CAL,LCA_NOTA" > $convocatoria/Actas${course}.csv
	fi

	if [ $course == '3ESO' ]
	then
		echo "Curso,Grupo,Orden,Alumno,Repetidor,PTE_1,PTE_2,BG_CAL,BG_NOTA,FQ_CAL,FQ_NOTA,GH_CAL,GH_NOTA,LCL_CAL,LCL_NOTA,PLE,PLE_CAL,PLE_NOTA,MAT,MAT_CAL,MAT_NOTA,EF_CAL,EF_NOTA,RELVE,RELVE_CAL,RELVE_NOTA,MUS_CAL,MUS_NOTA,ESP,ESP_CAL,ESP_NOTA,EPVA_CAL,EPVA_NOTA,VLL_CAL,VLL_NOTA,LCA,LCA_CAL,LCA_NOTA" > $convocatoria/Actas${course}.csv
	fi

	if [ $course == '4ESO' ]
	then
		echo "Curso,Grupo,Orden,Alumno,Opcion,Repetidor,PTE_1,PTE_2,PTE_3,GH_CAL,GH_NOTA,LCL_CAL,LCL_NOTA,PLE,PLE_CAL,PLE_NOTA,MAT,MAT_CAL,MAT_NOTA,TR1,TR1_CAL,TR1_NOTA,TR2,TR2_CAL,TR2_NOTA,EF_CAL,EF_NOTA,RELVE,RELVE_CAL,RELVE_NOTA,OPCA,OPCA_CAL,OPCA_NOTA,OPCB,OPCB_CAL,OPCB_NOTA,VLL_CAL,VLL_NOTA" > $convocatoria/Actas${course}.csv
	fi

	# Process every file in the $course directory
	for filename in ./$convocatoria/$course/*.pdf; do
				
		#Remove all the file name until the group name
		group=${filename##*[[:blank:]]} 
		#Remove all the file name (.pdf extension) after the group name
		group=${group%.*}
		level=${group:0:4}
		# java command -> Extract table info from PDF
		# grep command -> Get only rows starting with numbers
		# sed command (1st & 2nd) -> Append the course and group name at the beggining of each line
		# sed command (3rd & 4th) -> Add 0 as pending subjects from previous years
		#echo "##########################"
		echo "Procesando grupo $group..."
		#java -jar ./tabula-1.0.2-jar-with-dependencies.jar -d -l -p all "$filename" | grep "^\d" | sed "s/^/${group},/"
		# El primer grep parece que falla a veces.
		#java -jar ./tabula-1.0.2-jar-with-dependencies.jar -d -l -p all "$filename" | grep "^\d" | sed "s/^/${group},/" | sed "s/^/${level},/" | sed 's/,,/,0,/g' | sed 's/,,/,0,/g' >> Actas${course}.csv 2>/dev/null
		java -jar ./libs/ScriptTabula/tabula-1.0.2-jar-with-dependencies.jar -d -l -p all "$filename" | awk '/^[[:blank:]]*[0-9]/{print}' | sed "s/^/${group},/" | sed "s/^/${level},/" | sed 's/,,/,0,/g' | sed 's/,,/,0,/g' >> $convocatoria/Actas${course}.csv 2>/dev/null
    
    done

done

# Realizar un proceso especial para las actas de los grupos que trabajan por ámbitos
# 3ESOG
#Check if output file exists and delete it
echo "Gestionando ámbitos PMAR..."
rm -f $convocatoria/Actas3ESO_modified.csv
## El resto de grupos se dejan igual
cat $convocatoria/Actas3ESO.csv | awk -F',' 'BEGIN { OFS="," } ! /3ESOG/ {print}' >> $convocatoria/Actas3ESO_modified.csv
## En el grupo especial se hace el cambio de ámbitos a asignaturas y se reordenan los campos
cat $convocatoria/Actas3ESO.csv | awk -F',' 'BEGIN { OFS="," } /3ESOG/ {print $1,$2,$3,$4,$5,$6,$7,$8,$11,$12,$11,$12,$9,$10,$9,$10,$13,$14,$15,"MAP",$11,$12,$16,$17,$18,$19,$20,$21,$22,$25,$26,$27,$23,$24,$9,$10,$28,$29,$30}' >> $convocatoria/Actas3ESO_modified.csv
mv $convocatoria/Actas3ESO_modified.csv $convocatoria/Actas3ESO.csv

