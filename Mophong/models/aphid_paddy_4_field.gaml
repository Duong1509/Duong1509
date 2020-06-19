model aphid

global {
    int nb_aphids_init <- 135;
    float aphid_max_energy <- 1.0;
    float aphid_max_transfer <- 0.1;
    float aphid_energy_consum <- 0.025;

    float aphid_proba_reproduce <- 0.01;
    int aphid_nb_max_offsprings <- 3;
    float aphid_energy_reproduce <- 0.6;
    float aphid_energy_move <- 0.5;
    
    int nb_aphids -> {length (aphid)};
    int nb_paddy;
    int scale <- 42;
    float ratio;
    string file_name <- "result.csv";
    
    file map_init <- image_file("../includes/color3.jpg"); //44x56
    //file map_init <- image_file("../includes/color4.jpg"); //42x58
    
    init {
	    create aphid number: nb_aphids_init{
	    } 
	    ask vegetation_cell {
	    color <- rgb (map_init at {grid_x,grid_y}) ;
	//    food <- 1.0;
	    food <- 1 - (((color as list) at 0) / 255) ;
	    food_prod <- food / 100 ; 
    }
	}

	reflex write_to_file {
		save [nb_aphids, nb_paddy] to:"result.csv"rewrite: (cycle = 0) ? true : false type:"csv";
	}
	//reflex stop_simulation when: (cycle=6000) {
	reflex stop_simulation when: (nb_aphids=0) {
        do pause ;
    } 
    
    reflex update_nb_paddy {
   		list<vegetation_cell> mycell <- (vegetation_cell where (each.food>0));
    	//nb_paddy <- int(length(mycell)/25);
    	nb_paddy <- int(length(mycell));
    	ratio<- length (aphid)/length(mycell);
    }
}

species aphid {
    float size <- 1.0 ;
    rgb color <- #blue;
    float max_energy <- aphid_max_energy ;
    float max_transfer <- aphid_max_transfer ;
    float energy_consum <- aphid_energy_consum ;
    
    float proba_reproduce <- aphid_proba_reproduce;
    int nb_max_offsprings <- aphid_nb_max_offsprings;
    float energy_reproduce <- aphid_energy_reproduce;
    float energy_move <- aphid_energy_move;
        
    vegetation_cell my_cell <- one_of (vegetation_cell) ; 
    // vegetation_cell my_cell <- one_of(vegetation_cell where (each.grid_x < scale and each.grid_y < scale));
    float energy <- rnd(0.2) update: energy - energy_consum max: max_energy ;
        
    init { 
        location <- my_cell.location;
    }
        
    reflex basic_move 
    when: energy >= energy_move
      { 
    my_cell <- one_of (my_cell.neighbors2) ;
    location <- my_cell.location ;
    }
    reflex eat when: my_cell.food > 0 { 
    float energy_transfer <- min([max_transfer, my_cell.food]) ;
    my_cell.food <- my_cell.food - energy_transfer ;
    energy <- energy + energy_transfer ;
    }
    reflex die when: energy <= 0 {
    do die ;
    }
    
    reflex reproduce when: (energy >= energy_reproduce) and (flip(proba_reproduce)) {
        int nb_offsprings <- rnd(1, nb_max_offsprings);
        create species(self) number: nb_offsprings {
            my_cell <- myself.my_cell;
            location <- my_cell.location;
            energy <- 0.2;
        }

        energy <- energy - 0.1;
    }

    aspect base {
    draw circle(size) color: color ;
    }
}


grid vegetation_cell width: 100 height: 100 neighbors: 4 {
    float max_food <- 1.0 ;
    float food_prod  ;
    float food  max: max_food   ;
    rgb color <- rgb(int(255 * (1 - food)), 255, int(255 * (1 - food))) update: rgb(int(255 * (1 - food)), 255, int(255 *(1 - food))) ;
   list<vegetation_cell> neighbors2  <- (self neighbors_at 2);
  //  list<vegetation_cell> neighbors2  <- self.neighbors;    
	reflex update_food when: food>0  {
	food<- food +food_prod;

    }
    
}

experiment aphid_paddy type: gui {
    parameter "Initial number of aphids: " var: nb_aphids_init min: 1 max: 1000 category: "aphid" ;
    parameter "aphid max energy: " var: aphid_max_energy category: "aphid" ;
    parameter "aphid max transfer: " var: aphid_max_transfer  category: "aphid" ;
    parameter "aphid energy consumption: " var: aphid_energy_consum  category: "aphid" ;
    parameter 'aphid probability reproduce: ' var: aphid_proba_reproduce category: 'aphid';
    parameter 'aphid nb max offsprings: ' var: aphid_nb_max_offsprings category: 'aphid';
    parameter 'aphid energy reproduce: ' var: aphid_energy_reproduce category: 'aphid'; 
    parameter 'aphid energy move: ' var: aphid_energy_move category: 'aphid';
    output {
    display main_display {
        grid vegetation_cell lines: #black ;
        species aphid aspect: base ;
    }
    		display Population_information refresh_every: 5 {
			chart "Species evolution" type: series size: {1,0.5} position: {0, 0} {
				data "number_of_aphids" value: nb_aphids color: #blue ;
				data "number_of_paddy" value: nb_paddy/100 color: #green ;

			}
			}
			
			
		    		//display ratio_information refresh_every: 5 {
			//chart "Species evolution" type: series size: {1,0.5} position: {0, 0} {
			//	data "ratio" value: ratio color: #black ;


			//}
			//}
    monitor "Number of aphids" value: nb_aphids ;
    monitor "Number of paddy" value: nb_paddy ;
    }
}