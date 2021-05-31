$(document).ready(function(){
    $("table.categorized input:checkbox.header").click(function(){//producer checkbox was clicked (category header)
    	$(this).parent().css("background-color","white");
    	var isChecked = $(this).prop("checked");
    	$("input:checkbox."+$(this).prop("id")).each(function(){// select/deselect all query checkboxes belonging to this producer checkbox category
    		$(this).prop("checked",isChecked);
    	});
    });
    
    $("table.categorized input:checkbox:not(.header)").click(function(){//query checkbox was clicked
    	var className;
    	if($(this).hasClass("activeProducer")){
    		className="activeProducerCheckboxId_";
    	}else{
    		className="complexProducerCheckboxId_";
    	}
    	var classList = $(this).prop('class').split(/\s+/);
    	$(classList).each(function(){
    		if(className == this.substring(0, className.length )){//find this checkbox category header checkbox and select/deselect and/or color it
    			$("#"+this).each(function(){//there is only one actually
    				var checkedCount = $("input:checkbox:checked."+$(this).prop("id")).length;//find how many this category checkboxes are checked
    		    	var notCheckedCount = $("input:checkbox:not(:checked)."+$(this).prop("id")).length;
    		    	if(checkedCount > 0 && notCheckedCount==0){
    		    		$(this).prop("checked","true");
    		    		$(this).parent().css("background-color","white");
    		    	}else if(checkedCount > 0){
    		    		$(this).prop("checked","");
    		    		$(this).parent().css("background-color","#E0E0E0");//light grey
    		    	}else{
    		    		$(this).prop("checked","");
    		    		$(this).parent().css("background-color","white");
    		    	}
    			});
    		}
    	});
    });
	
	$("form[name='queriesImport'], form[name='queriesExport']").submit(function(){
        var confirmMessage = $(this).find(":hidden[name='confirmMessage']").val();
		if(confirm(confirmMessage)==false)return false;
        var data = new Object();        
        var producers = new Object();
        data.producers = producers;        
        
        $("input:checkbox.activeProducer.header").each(function(){//pick up activeProducers queries id-s
        	var id = $(this).prop("id");
        	var idNumeric = id.substring("activeProducerCheckboxId_".length );
        	var elements = $("input:checkbox:checked."+id);
        	if(elements.length > 0 || $(this).prop("checked")){
        		producers[idNumeric] = new Array();
        		elements.each(function(){
        			producers[idNumeric].push(this.value);
        		});
        	}
        });
        
        $("input:checkbox.complexProducer.header").each(function(){//pick up complexProducers queries id-s
        	var id = $(this).prop("id");
        	var idNumeric = id.substring("complexProducerCheckboxId_".length );
        	var elements = $("input:checkbox:checked."+id);
        	if(elements.length > 0 || $(this).prop("checked")){
        		producers[idNumeric] = new Array();
        		elements.each(function(){
        			producers[idNumeric].push(this.value);
        		});
        	}
        });
        
        var dataString = JSON.stringify(data);
        $(this).find(":hidden[name='data']").val(dataString);
        return true;
    });
});