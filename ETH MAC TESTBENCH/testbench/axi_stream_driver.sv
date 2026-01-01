class axi_stream_driver extends uvm_driver #(axi_stream_pkt);
    virtual axi_stream_if vif;

    `uvm_component_utils(axi_stream_driver)

    function new(string name="axi_stream_driver", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual axi_stream_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF","No virtual interface set for driver");
    endfunction

    task run_phase(uvm_phase phase);
        axi_stream_pkt tr;
        vif.tvalid <= 0;
        vif.tlast  <= 0;
        vif.tuser  <= 0;

        forever begin
            seq_item_port.get_next_item(tr);

            for(int i=0;i<tr.data.size();i++) begin
                @(posedge vif.clk);
                vif.tvalid <= 1;
                vif.tdata  <= tr.data[i];
                vif.tlast  <= (i == tr.data.size()-1);
                vif.tuser  <= 0;

                wait(vif.tready);
            end

            @(posedge vif.clk);
            vif.tvalid <= 0;
            vif.tlast  <= 0;

            seq_item_port.item_done();
        end
    endtask
endclass
