class Proyecto
  include Mongoid::Document
  include Mongoid::Timestamps

  index :id_proyecto_ley
  
  # fields suitable for duplicating on related documents
  def self.basic_fields
    [
      :id_proyecto_ley, :nro_boletin, :titulo, :titulo_sesion, 
      :fecha_ingreso, :iniciativa, :tipo, :camara_origen, :urgencia,
      :etapa, :sub_etapa, :ley, :ley_bcn, :decreto, :decreto_bcn,
      :fecha_publicacion, :id_materia, :nro_interno, :avance,
      :nro_tramitacion, :tramitacion_act, :resumen
    ]
  end
end

class Comision
  include Mongoid::Document
  include Mongoid::Timestamps

  index :id_comision
  
  def self.basic_fields
    [
      :id_comision, :nombre, :tipo, :camara, :contacto_mail, 
      :contacto_tel, :contacto_form, :abogado_secretario, :abogado_ayudante,
      :secretario_ejecutivo
    ]
  end
end

class Parlamentario
  include Mongoid::Document
  include Mongoid::Timestamps
  
  index :id_parlamentario
  
  def self.basic_fields
    [
      :activo, :apellidos, :cargos_eleccion, :cargos_gobierno, :comisiones_actuales, 
      :comisiones_anteriores, :comite_parlamentario, :declaracion_interes, 
      :declaracion_patrimonio, :dietas, :educacion_postgrado, :educacion_universitaria, 
      :experiencia_laboral, :experiencia_politica, :facebook, :fecha_nacimiento, 
      :financiamiento_electoral2005, :gasto_electoral2005, :id_circunscripcion, 
      :id_parlamentario, :id_parlamento, :id_partido, :mail, :mesa_directiva, :nombre, 
      :pacto, :periodos_diputado, :periodos_diputado_desc, :periodos_senador, 
      :periodos_senador_desc, :primera_vez, :profesion, :senador_diputado, :sexo, 
      :twitter, :voto_nro, :voto_porcentaje, :web
    ]
  end
end

class Votacion
  include Mongoid::Document
  include Mongoid::Timestamps
  
  index :id_votacion
  index :id_proyecto_ley
end

class Debate
  include Mongoid::Document
  include Mongoid::Timestamps
  
  index :id_debate
  index :id_proyecto_ley
  index :comision_sala
  index :camara
  index :comisiones_unidas
end


# record information about every API request
class Hit
  include Mongoid::Document
  
  index :created_at
  index :method
  index :sections
  index :user_agent
end
